chai = require "chai"
should = chai.should()

sh2png = require "../src/sh2png"
shouldMatch = require "./match"

char = "✓"

describe "Characters missing from Ubuntu Mono (#{char})", ->
  
  describe "printed in default font", ->
    formatted = null
    
    it "formats the string", ->
      formatted = sh2png.format char
    
    it "is writable", ->
      formatted.then (img) ->
        img.writeAsync "#{__dirname}/output/missing-character-default-font.png"
    
    shouldMatch "missing-character-default-font.png"
  
  describe "printed in custom font", ->
    formatted = null
    
    it "formats the string", ->
      formatted = sh2png.format char,
        fonts: "#{__dirname}/mocha-test/DejaVu_Sans_Mono_Symbols_16pt.fnt"
      
    it "is writable", ->
      formatted.then (img) ->
        img.writeAsync "#{__dirname}/output/missing-character-custom-font.png"
      
    shouldMatch "missing-character-custom-font.png"
  
  describe "printed using fallback font", ->
    formatted = null
    
    it "formats the string", ->
      formatted = sh2png.format "Special character: #{char}",
        fonts: [
          "#{__dirname}/../font/Ubuntu_Mono_16pt.fnt",
          "#{__dirname}/mocha-test/DejaVu_Sans_Mono_Symbols_16pt.fnt"]
    
    it "is writable", ->
      formatted.then (img) ->
        img.writeAsync "#{__dirname}/output/missing-character-fallback-font.png"
    
    shouldMatch "missing-character-fallback-font.png"