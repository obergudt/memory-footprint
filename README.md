# memory-footprint

This tiny tool will scan a `package.json` files dependencies, load them one by one an measure the memory footprint of loading them.

## As a binary

Run `memory-footprint path/to/package.json` or `memory-footprint --file path/to/package.json`.

## Run locally

Run `npm start path/to/package.json`.

## All options

### `--file path/to/package.json`

- Specify a file to load all dependencies from. The modules will be loaded from the `node_modules` folder in the directory the `package.json` file is located at.

### `--interval`

- Default: 25
- Memory footprints will be taken every x milliseconds.

### `--times`

- Default: 5
- Memory footprints will be taken x times in a row before the next module is loaded.

### `--runs`

- Default : 2
- The whole list of modules will be unloaded and re-loaded x times.

### `--delay`

- Default : 1000
- Betweens runs, the tool will wait x ms for garbage collection and the unloading to finish.


## License: MIT