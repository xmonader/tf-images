import crypto from 'node:crypto'

import fse from 'fs-extra'
import yaml from 'js-yaml'
import {type Compose} from 'compose-spec-schema'
import {$} from 'execa'
import systemInformation from 'systeminformation'
import fetch from 'node-fetch'
import stripAnsi from 'strip-ansi'
import pRetry from 'p-retry'

import getDirectorySize from '../utilities/get-directory-size.js'
import {pullAll} from '../utilities/docker-pull.js'

import type Umbreld from '../../index.js'
import {type AppManifest} from './schema.js'

import appScript from './legacy-compat/app-script.js'

async function readYaml(path: string) {
	return yaml.load(await fse.readFile(path, 'utf8'))
}

async function writeYaml(path: string, data: any) {
	return fse.writeFile(path, yaml.dump(data))
}

async function patchYaml(path: string) {
	let yaml = await fse.readFile(path, 'utf8')

	const find = '$APP_LIGHTNING_NODE_REST_PORT:$APP_LIGHTNING_NODE_REST_PORT'
	if (!yaml.includes(find)) return true
	yaml = yaml.replace(find, '8558:$APP_LIGHTNING_NODE_REST_PORT');

	await fse.writeFile(path, yaml)
	return true
}

type AppState =
	| 'unknown'
	| 'installing'
	| 'starting'
	| 'running'
	| 'stopping'
	| 'stopped'
	| 'restarting'
	| 'uninstalling'
	| 'updating'
	| 'ready'
// TODO: Change ready to running.
// Also note that we don't currently handle failing events to update the app state into a failed state.
// That should be ok for now since apps rarely fail, but there will be the potential for state bugs here
// where the app instance state gets out of sync with the actual state of the app.
// We can handle this much more robustly in the future.

export default class App {
	#umbreld: Umbreld
	logger: Umbreld['logger']
	id: string
	dataDirectory: string
	state: AppState = 'unknown'
	stateProgress = 0

	constructor(umbreld: Umbreld, appId: string) {
		// Throw on invalid appId
		if (!/^[a-zA-Z0-9-_]+$/.test(appId)) throw new Error(`Invalid app ID: ${appId}`)

		this.#umbreld = umbreld
		this.id = appId
		this.dataDirectory = `${umbreld.dataDirectory}/app-data/${this.id}`
		const {name} = this.constructor
		this.logger = umbreld.logger.createChildLogger(name.toLowerCase())
	}

	readManifest() {
		return readYaml(`${this.dataDirectory}/umbrel-app.yml`) as Promise<AppManifest>
	}

	readCompose() {
		return readYaml(`${this.dataDirectory}/docker-compose.yml`) as Promise<Compose>
	}

	patchCompose() {
		return patchYaml(`${this.dataDirectory}/docker-compose.yml`)
	}

	async readHiddenService() {
		try {
			return await fse.readFile(`${this.#umbreld.dataDirectory}/tor/data/app-${this.id}/hostname`, 'utf-8')
		} catch (error) {
			this.logger.error(`Failed to read hidden service for app ${this.id}: ${(error as Error).message}`)
			return ''
		}
	}

	async deriveDeterministicPassword() {
		const umbrelSeed = await fse.readFile(`${this.#umbreld.dataDirectory}/db/umbrel-seed/seed`)
		const identifier = `app-${this.id}-seed-APP_PASSWORD`
		const deterministicPassword = crypto.createHmac('sha256', umbrelSeed).update(identifier).digest('hex')

		return deterministicPassword
	}

	writeCompose(compose: Compose) {
		return writeYaml(`${this.dataDirectory}/docker-compose.yml`, compose)
	}

	async patchComposeServices() {
		// Temporary patch to fix contianer names for modern docker-compose installs.
		// The contianer name scheme used to be <project-name>_<service-name>_1 but
		// recent versions of docker-compose use <project-name>-<service-name>-1
		// swapping underscores for dashes. This breaks Umbrel in places where the
		// containers are referenced via name and it also breaks referring to other
		// containers via DNS since the hostnames are derived with the same method.
		// We manually force all container names to the old scheme to maintain compatibility.
		const compose = await this.readCompose()
		for (const serviceName of Object.keys(compose.services!)) {
			if (!compose.services![serviceName].container_name) {
				compose.services![serviceName].container_name = `${this.id}_${serviceName}_1`
			}
		}

		await this.writeCompose(compose)
		await this.patchCompose()
	}

	async pull() {
		const defaultImages = [
			'getumbrel/app-proxy:1.0.0@sha256:49eb600c4667c4b948055e33171b42a509b7e0894a77e0ca40df8284c77b52fb',
			'getumbrel/tor:0.4.7.8@sha256:2ace83f22501f58857fa9b403009f595137fa2e7986c4fda79d82a8119072b6a',
		]
		const compose = await this.readCompose()
		const images = Object.values(compose.services!)
			.map((service) => service.image)
			.filter(Boolean) as string[]
		await pullAll([...defaultImages, ...images], (progress) => {
			this.stateProgress = Math.max(1, progress * 99)
			this.logger.log(`Downloaded ${this.stateProgress}% of app ${this.id}`)
		})
	}

	async install() {
		this.state = 'installing'
		this.stateProgress = 1

		await this.patchComposeServices()
		await this.pull()

		await pRetry(() => appScript(this.#umbreld, 'install', this.id), {
			onFailedAttempt: (error) => {
				this.logger.error(
					`Attempt ${error.attemptNumber} installing app ${this.id} failed. There are ${error.retriesLeft} retries left.`,
				)
			},
			retries: 2,
		})
		this.state = 'ready'
		this.stateProgress = 0

		return true
	}

	async update() {
		this.state = 'updating'
		this.stateProgress = 1

		// TODO: Pull images here before the install script and calculate live progress for
		// this.stateProgress so button animations work

		this.logger.log(`Updating app ${this.id}`)

		// Get a reference to the old images
		const compose = await this.readCompose()
		const oldImages = Object.values(compose.services!)
			.map((service) => service.image)
			.filter(Boolean) as string[]

		// Update the app, patching the compose file half way through
		await appScript(this.#umbreld, 'pre-patch-update', this.id)
		await this.patchComposeServices()
		await this.pull()
		await appScript(this.#umbreld, 'post-patch-update', this.id)

		// Delete the old images if we can. Silently fail on error cos docker
		// will return an error even if only one image is still needed.
		try {
			await $({stdio: 'inherit'})`docker rmi ${oldImages}`
		} catch {}

		this.state = 'ready'
		this.stateProgress = 0

		return true
	}

	async start() {
		this.logger.log(`Starting app ${this.id}`)
		this.state = 'starting'
		// We re-run the patch here to fix an edge case where 0.5.x imported apps
		// wont run because they haven't been patched.
		await this.patchComposeServices()
		await pRetry(() => appScript(this.#umbreld, 'start', this.id), {
			onFailedAttempt: (error) => {
				this.logger.error(
					`Attempt ${error.attemptNumber} starting app ${this.id} failed. There are ${error.retriesLeft} retries left.`,
				)
			},
			retries: 2,
		})
		this.state = 'ready'

		return true
	}

	async stop() {
		this.state = 'stopping'
		await pRetry(() => appScript(this.#umbreld, 'stop', this.id), {
			onFailedAttempt: (error) => {
				this.logger.error(
					`Attempt ${error.attemptNumber} stopping app ${this.id} failed. There are ${error.retriesLeft} retries left.`,
				)
			},
			retries: 2,
		})
		this.state = 'stopped'

		return true
	}

	async restart() {
		this.state = 'restarting'
		await appScript(this.#umbreld, 'stop', this.id)
		await appScript(this.#umbreld, 'start', this.id)
		this.state = 'ready'

		return true
	}

	async uninstall() {
		this.state = 'uninstalling'
		await pRetry(() => appScript(this.#umbreld, 'stop', this.id), {
			onFailedAttempt: (error) => {
				this.logger.error(
					`Attempt ${error.attemptNumber} stopping app ${this.id} failed. There are ${error.retriesLeft} retries left.`,
				)
			},
			retries: 2,
		})
		await appScript(this.#umbreld, 'nuke-images', this.id)
		await fse.remove(this.dataDirectory)

		await this.#umbreld.store.getWriteLock(async ({get, set}) => {
			let apps = (await get('apps')) || []
			apps = apps.filter((appId) => appId !== this.id)
			await set('apps', apps)

			// Remove app from recentlyOpenedApps
			let recentlyOpenedApps = (await get('recentlyOpenedApps')) || []
			recentlyOpenedApps = recentlyOpenedApps.filter((appId) => appId !== this.id)
			await set('recentlyOpenedApps', recentlyOpenedApps)

			// Disable any associated widgets
			let widgets = (await get('widgets')) || []
			widgets = widgets.filter((widget) => !widget.startsWith(`${this.id}:`))
			await set('widgets', widgets)
		})

		return true
	}

	async getPids() {
		const compose = await this.readCompose()
		const containers = Object.values(compose.services!).map((service) => service.container_name) as string[]
		containers.push(`${this.id}_app_proxy_1`)
		containers.push(`${this.id}_tor_server_1`)
		const pids = await Promise.all(
			containers.map(async (container) => {
				try {
					const top = await $`docker top ${container}`
					return top.stdout
						.split('\n') // Split on newline
						.slice(1) // Remove header
						.map((line) => parseInt(line.split(/\s+/)[1], 10)) // Split on whitespace and get second item (PID)
				} catch (error) {
					// If we fail to get the PID, return an empty array and continue for the other contianers
					// We don't log this error cos we'll expect to get it on some misses for the app proxy
					// and tor server contianers.
					return []
				}
			}),
		)

		return pids.flat()
	}

	async getDiskUsage() {
		try {
			// Disk usage calculations can fail if the app is rapidly moving files around
			// since files in directories will be listed and then iterated over to have
			// their size summed up. If a file is moved between these two operations it
			// will fail. It happens rarely so simply retrying will catch most cases.
			return await pRetry(() => getDirectorySize(this.dataDirectory), {retries: 2})
		} catch (error) {
			this.logger.error(`Failed to get disk usage for app ${this.id}: ${(error as Error).message}`)
			return 0
		}
	}

	async getLogs() {
		const inheritStdio = false
		const result = await appScript(this.#umbreld, 'logs', this.id, inheritStdio)
		return stripAnsi(result.stdout)
	}

	async getContainerIp(service: string) {
		// Retrieve the container name from the compose file
		// This works because we have a temporary patch to force all container names to the old Compose scheme to maintain compatibility between Compose v1 and v2
		const compose = await this.readCompose()
		const containerName = compose.services![service].container_name

		if (!containerName) throw new Error(`No container_name found for service ${service} in app ${this.id}`)

		const {stdout: containerIp} =
			await $`docker inspect -f {{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}} ${containerName}`

		return containerIp
	}

	// Returns a specific widget's info from an app's manifest
	async getWidgetMetadata(widgetName: string) {
		const manifest = await this.readManifest()
		if (!manifest.widgets) throw new Error(`No widgets found for app ${this.id}`)

		const widgetMetadata = manifest.widgets.find((widget) => widget.id === widgetName)
		if (!widgetMetadata) throw new Error(`Invalid widget ${widgetName} for app ${this.id}`)

		return widgetMetadata
	}

	// Returns a specific widget's data
	async getWidgetData(widgetId: string) {
		// Get widget info from the app's manifest
		const widgetMetadata = await this.getWidgetMetadata(widgetId)

		const url = new URL(`http://${widgetMetadata.endpoint}`)
		const service = url.hostname

		url.hostname = await this.getContainerIp(service)

		try {
			const response = await fetch(url)

			if (!response.ok) throw new Error(`Failed to fetch data from ${url}: ${response.statusText}`)

			const widgetData = (await response.json()) as {[key: string]: any}
			return widgetData
		} catch (error) {
			if (error instanceof Error) {
				throw new Error(`Failed to fetch data from ${url}: ${error.message}`)
			} else {
				throw new Error(`An unexpected error occured while fetching data from ${url}: ${error}`)
			}
		}
	}
}
