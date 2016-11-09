chai = require "chai"
should = chai.should()

sh2png = require "../src/sh2png"
shouldMatch = require "./match"

describe "Formatting a Single Line, no Escape Codes", ->

  formatted = sh2png.format "Hello World"

  it "is writable", ->
    formatted.then (img) ->
      img
        .writeAsync "#{__dirname}/output/oneliner.png"

  shouldMatch "oneliner.png"

describe "Formatting Multiple Lines, no Escape Codes", ->

  formatted = sh2png.format """
    Hello World!
    This is a sample string that has multiple lines, of various sizes.
        See ya!
  """

  it "is writable", ->
    formatted.then (img) ->
      img.writeAsync "#{__dirname}/output/block.png"

  shouldMatch "block.png"
