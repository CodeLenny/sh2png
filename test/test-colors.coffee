chai = require "chai"
should = chai.should()

sh2png = require "../src/sh2png"
shouldMatch = require "./match"

colors =
  "39": "default"
  "30": "black"
  "31": "red"
  "32": "green"
  "33": "yellow"
  "34": "blue"
  "35": "magenta"
  "36": "cyan"
  "37": "white"

describe "Simple Strings with Normal Colors", ->

  for own code, color of colors
    do (code, color) ->

      cap = "#{color[0].toUpperCase()}#{color.slice 1}"
      display = "\x1b[#{code}m#{cap}\x1b[0m"
      input = "\\x1b[#{code}m#{cap}\\x1b[0m"
      describe "#{display} String", ->

        formatted = sh2png.format input,
          width: color.length

        it "is writable", ->
          formatted.then (img) ->
            img.writeAsync "#{__dirname}/output/simple-color-normal-#{color}.png"

        shouldMatch "simple-color-normal-#{color}.png"
