chai = require "chai"
should = chai.should()

Promise = require "bluebird"
fs = Promise.promisifyAll require "fs"
{exec} = require "child-process-promise"
shouldMatch = require "./match"

regex =
  base64Prefix: /data:image\/(?:jpeg|png|bmp);base64,/

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

  for format in ["png", "jpg", "bmp"]
      do (format) ->
        describe "'--format #{format}'", ->
          it "should run", ->
            @timeout 10 * 1000
            exec "echo 'Testing' | #{sh2png} --format #{format} - > #{__dirname}/output/console-format-stdout-format.#{format}"

          shouldMatch "console-format-stdout-format.#{format}"

        describe "'--format #{format} --base64'", ->
          file64 = "console-format-base64.#{format}-64"
          file64decoded = "console-format-base64.#{format}"
          it "should run", ->
            @timeout 10 * 1000
            exec "echo 'Testing' | #{sh2png} --format #{format} --base64 - > #{__dirname}/output/#{file64}"

          shouldMatch file64

          it "should convert to #{format}", ->
            fs
              .readFileAsync "#{__dirname}/output/#{file64}", "utf8"
              .then (raw) ->
                base64 = raw.replace(regex.base64Prefix, "")
                img = new Buffer(base64, 'base64')
                fs.writeFileAsync "#{__dirname}/output/#{file64decoded}", img

          shouldMatch file64decoded

        describe "'--output output.#{format}'", ->
          it "should run", ->
            @timeout 10 * 1000
            exec "echo 'Testing' | #{sh2png} -o #{__dirname}/output/console-format-output.#{format} -"

          shouldMatch "console-format-output.#{format}"

        describe "'--output output.#{format} --base64'", ->

          file64 = "console-format-output-base64.#{format}-64"
          file64decoded = "console-format-output-base64.#{format}"

          it "should run", ->
            @timeout 10 * 1000
            exec "echo 'Testing' | #{sh2png} -o #{__dirname}/output/#{file64} --base64 --format #{format} -"

          shouldMatch file64

          it "should convert to #{format}", ->
            fs
              .readFileAsync "#{__dirname}/output/#{file64}", "utf8"
              .then (raw) ->
                base64 = raw.replace(regex.base64Prefix, "")
                img = new Buffer(base64, 'base64')
                fs.writeFileAsync "#{__dirname}/output/#{file64decoded}", img

          shouldMatch file64decoded
