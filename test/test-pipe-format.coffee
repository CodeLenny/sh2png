chai = require "chai"
should = chai.should()
{exec} = require "child-process-promise"
shouldMatch = require "./match"

sh2png = "coffee #{__dirname}/../src/console.coffee"

describe "sh2png piped", ->

  describe "Basic Usage", ->

    it "should run", ->
      @timeout 45 * 1000
      exec "#{sh2png} --help | #{sh2png} piped > #{__dirname}/output/console-format-stdout.png"

    shouldMatch "console-format-stdout.png"

  describe "Using alias '-'", ->

    it "should run", ->
      @timeout 10 * 1000
      exec "echo 'Testing' | #{sh2png} - > #{__dirname}/output/console-format-stdout-alias.png"

    shouldMatch "console-format-stdout-alias.png"

  describe "'--format jpg'", ->

    it "should run", ->
      @timeout 10 * 1000
      exec "echo 'Testing' | #{sh2png} --format jpg - > #{__dirname}/output/console-format-stdout-format.jpg"

    shouldMatch "console-format-stdout-format.jpg"
