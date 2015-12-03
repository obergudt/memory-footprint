argv        = require("minimist")(process.argv.slice(2))
ProgressBar = require('progress')
fs          = require "fs"
path        = require "path"

if not global?.gc 
  console.log "Please start this program with node --expose-gc to allow manual garbage collection"
  exit(2)

# Load the file passed in the arguments object, check if there
# are dependencies. Those will be loaded from the node_module
# directory of the package file
try 
  relevantFile = argv.file or if argv["_"].length is 1 then argv["_"][0] else './package.json'
  relevantDir = path.dirname relevantFile
  contents = fs.readFileSync relevantFile, 'utf8'
  c = JSON.parse contents
  
  # The mods array will retain all relevant module names
  mods = []
  for key of c.dependencies 
    mods.push key

catch e 
  console.log "Could not read Modules from file #{argv.file}"
  process.exit(1)

finalStats = []
loadedMods = []
results = []
index = 0
runs = 0
measureInterval = parseInt(argv.interval,10) or 25
measureCount = parseInt(argv.times,10) or 5
runCount = parseInt(argv.runs,10) or 2
runDelay = parseInt(argv.delay,10) or 1000
bar = new ProgressBar(':bar :percent (:etas left)', { total: mods.length*runCount })

console.log """
================
Memory Footprint
================

Testing #{mods.length} modules.
Measuring every #{measureInterval}ms, #{measureCount} times.
Running #{runCount} times with a #{runDelay}ms delay.
"""

# Measure the mod at the index in the mods array
checkMod = (index)->

  # We have checked all mods. We will sort and calculate stats
  if index >= mods.length
    stats = finalStats.sort (a,b)->
      if a.size > b.size 
        return -1
      else if a.size < b.size 
        return 1
      else 
        return 0

    stats = finalStats

    results.push stats

    # New Run scheduled
    if runs < runCount-1
      _ = require "underscore"
      runs++
      index = 0
      loadedMods = [] 
      finalStats = []
      _.each _.keys(require.cache), (key) ->
        delete require.cache[key]   

      global?.gc?()

      setTimeout ->
        checkMod(index)
      , runDelay
    else
      # console.log "\n"
      aggregate = {}
      sorted = []
      
      for item in results[0]
        aggregate[item.name] = []
        for result in results
          for resultItem in result 
            if resultItem.name is item.name 
              aggregate[item.name].push resultItem.size 
      
      for key,value of aggregate 
        value = (1/value.length)*value.reduce (p,c)->
          if p >= 0 and c > 0
            return p+c
          else 
            return p
        , 0
        sorted.push
          name : key 
          size : value

      sorted = sorted.sort (a,b)->
        if a.size > b.size 
          return -1
        else if a.size < b.size 
          return 1
        else 
          return 0
      for item in sorted 
        console.log item.name,":",require("filesize")(item.size or 0)
      process.exit(0)

  # The module needs to be measured
  else

    moduleMeasureCount = measureCount
    measurePoints = []

    # Load the module from the directory/node_modules of the 
    # package.json passed as an argument to --file
    try 
      global.gc()
      initial = process.memoryUsage()
      m = require path.join relevantDir, "node_modules", mods[index] 
      loadedMods.push m

    # If it can't be loaded, we skip it
    catch e 
      global.gc()
      bar.tick()
      checkMod(++index)
      return

    interval = setInterval ->
      
      loaded = process.memoryUsage()
      measurePoints.push loaded.rss - initial.rss
      moduleMeasureCount--
      initial = loaded

      # After measuring, we add the increases/decreases and push 
      # to the stats collection for this run
      if moduleMeasureCount is 0 
        size = measurePoints.reduce (previousValue, currentValue) ->
          if previousValue >= 0 and currentValue > 0
            return previousValue + currentValue          
          else 
            return previousValue
        , 0
        finalStats.push 
          name : mods[index]
          size : size 
        bar.tick()
        checkMod(++index)      
        clearInterval interval
    , measureInterval

global.gc()
checkMod(index)
