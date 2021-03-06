{exec} = require "child-process-promise"

sh2png = require "../src/sh2png"
shouldMatch = require "./match"

describe "Formatting Mocha Output", ->

  mocha = null

  env = process.env
  env.FORCE_COLOR = 1

  it "should get Mocha output", ->
    mocha = exec "mocha --compilers coffee:coffee-script/register #{__dirname}/mocha-test/test-simple.coffee", {env}

  it "should format output", ->
    mocha
      .then ({stdout}) ->
        sh2png.format stdout.replace(/[0-9]+ms/, "7ms"),
          fonts: [
            "#{__dirname}/../font/Ubuntu_Mono_24pt.fnt",
            "#{__dirname}/mocha-test/DejaVu_Sans_Mono_Symbols_24pt.fnt"]
      .then (img) ->
        img.writeAsync "#{__dirname}/output/format-mocha.png"

  shouldMatch "format-mocha.png"
