# Alpine-based publishingtools image

With no ssh server, trc or caddy.

## Building

In the publishingtools directory.

```bash
docker build --force-rm -t {user/org}/publishingtools .
```

Better to use `--no-cache` when trying to update [publishingtools](https://github.com/crystaluniverse/publishingtools) version.

## Running

```bash
docker run -it -e NAME=<any name> -e TITLE=<any title> -e URL=<url to git repo> -e BRANCH=<repo branch> -e DOMAIN=<domain> {user/org}/publishingtools
```

Supported environment variables:

* NAME: site name
* TYPE: site type (www, wiki or blog)
* TITLE
* URL: site git url
* BRANCH
* DOMAIN
* SRCDIR: source directory (default is "src")

## Pushing

Consider tagging it with publishingtools version built with it, e.g:

```
docker push <org>/<name>:v1.0.0-alpha.18
```

Where `v1.0.0-alpha.18` is the publishingtools version when the image was built.

## Docker hub

Already published at [docker hub](https://hub.docker.com/r/abom/tfweb_alpine).
