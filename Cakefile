{exec} = require "child-process-promise"

task "build", "Compile source code", (opts) ->
  build opts
    .then ->
      console.log "Build done."

build = (opts) ->
  exec "$(npm bin)/coffee --compile --output dist/ src/"
    .then ->
      console.log "Built CoffeeScript source."
