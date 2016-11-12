Promise = require "bluebird"
{exec} = require "child-process-promise"

task "all", "Build source, generate documentation, and run tests", (opts) ->
  Promise.join build(opts), codo(opts), mocha(opts)
    .then ([b, c, m]) ->
      console.log c.stdout
      console.error c.stderr
      console.log m.stdout
      console.error m.stderr
    .catch (err) ->
      console.log err.stdout
      console.error err.stderr

task "build", "Compile source code", (opts) ->
  build opts
    .then (res) ->
      console.log res.stdout
      console.log res.stderr
      console.log "Build done."

task "docs", "Generate documentation", (opts) ->
  codo opts
    .then ->
      console.log "Documentation complete."

build = (opts) ->
  exec "$(npm bin)/coffee --compile --output dist/ src/"
    .then ->
      console.log "Built CoffeeScript source."

codo = (opts) ->
  exec "FORCE_COLOR=1 $(npm bin)/codo"

mocha = (opts) ->
  exec "FORCE_COLOR=1 PATH=\"$PATH:$(npm bin)\" mocha --compilers coffee:coffee-script/register"