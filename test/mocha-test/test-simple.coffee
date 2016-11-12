chai = require "chai"
should = chai.should()

describe "A Very Simple Mocha Run", ->

  it "Adds 1+2", ->
    (1+2).should.equal 3

  it "Adds 3+4", ->
    (3+4).should.equal 7
