## CHANGELOG
- `latest`:
    - `threefolddev/algorand:latest`
    - `https://hub.grid.tf/tf-official-apps/algorand-latest.flist`

- `v1.0-all`:
    Add the indexer option
    - `threefolddev/algorand:v1.0-all`
    - `https://hub.grid.tf/omarabdulaziz.3bot/threefolddev-algorand-v1.0-all.flist`

- `v1.0-rel`:
    Add the relay option
    - `threefolddev/algorand:v1.0-rel`
    - `https://hub.grid.tf/omarabdulaziz.3bot/threefolddev-algorand-v1.0-rel.flist`

- `v1.0-part`:
    First flist enable two options (default, participant)
    - `threefolddev/algorand:v1.0-part`
    - `https://hub.grid.tf/omarabdulaziz.3bot/threefolddev-algorand-v1.0-part.flist`

## ENVARs
```bash
SSH_KEY # your public ssh key
NETWORK # one of algorand nets [mainnet, testnet, betanet, devnet]
NODE_TYPE # algorand node type [default, relay, indexer]
ACCOUNT_MNEMONICS # account mnemonics that have some microalgo to do the participation transaction
FIRST_ROUND # first validation block (get it from algoexplorer or use 20M)
LAST_ROUND # last validation block (30M is reasonable range)
```

## Notes
For every update
- create new tag and describe the changes you made for a better history tracking.
- update the tag in the dockerfile
- promote to latest after you done, so all changes can be applied across all projects using the flist.
