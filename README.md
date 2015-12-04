# memory-footprint

This tiny tool will scan a `package.json` file's dependencies, load them one by one and measure the memory footprint of loading them. It will garbage collect before every load and after unloading. These figures may be inaccurate, but for the big picture, it's enough. 

## As a binary

Run `memory-footprint path/to/package.json` or `memory-footprint --file path/to/package.json`.

## Run locally

Run `npm start path/to/package.json`.

## All options

### `--file path/to/package.json`

- Specify a file to load all dependencies from. The modules will be loaded from the `node_modules` folder in the directory the `package.json` file is located at. 

### `--interval`

- Default: 25
- Memory footprints will be taken every x milliseconds. This should take into account internal automatic garbage collection. Only increases in memory consumption will be collected.

### `--times`

- Default: 5
- Memory footprints will be taken x times in a row before the next module is loaded. Some modules load their dependencies lazily, so make sure to give them enough time so measurements take into account these deferred assets.

### `--runs`

- Default : 2
- The whole list of modules will be unloaded and re-loaded x times. The module load order is randomized before every run. The more runs are executed, the more accurate the results will be.

### `--delay`

- Default : 1000
- Betweens runs, the tool will wait x ms for garbage collection and the unloading to finish.


## License: MIT