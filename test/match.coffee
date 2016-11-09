Promise = require "bluebird"
fs = Promise.promisifyAll require "fs"
{it} = require "mocha"
chai = require "chai"
should = chai.should()

###
Make sure that an outputted image matches a sample.
###
shouldMatch = (filename) ->
  it "should match sample/#{filename}", ->
    output = fs.readFileAsync("#{__dirname}/output/#{filename}")
    sample = fs.readFileAsync("#{__dirname}/sample/#{filename}")
    Promise
      .join output, sample
      .then ([output, sample]) ->
        output.length.should.equal sample.length
        Buffer.compare(output, sample).should.equal 0

module.exports = shouldMatch
