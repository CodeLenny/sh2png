class sh2png

  ###
  Given a string representing console output, convert the text into an image.

  @example Write output to file, using JavaScript callbacks
    sh2png = require("sh2png")
    output = "\\e[32mHello!\\e[0m"
    sh2png
      .format(output)
      .then(function(img) {
        img.write(__dirname+"/hello.png", function() {
          console.log(output+" written to hello.png");
        });
      });

  @example Get Base64'd output, using Promisified methods and CoffeeScript
    sh2png = require "sh2png"
    output = "\\e[32mHello!\\e[0m"
    sh2png
      .format output
      .then (img) -> img.getBase64Async "image/png"
      .then (base64) ->
        console.log "Base 64'd #{output}: #{base64}"

  @param {String} str console output to format.
  @option opts {String} font a path to a BMF font to use when drawing the image.  Defaults to Ubuntu Mono, included in
    `sh2png`.
  @return {Promise<Image>} a [JIMP](https://github.com/oliver-moran/jimp) image, which supports
    [`image.write(path, cb)`](https://github.com/oliver-moran/jimp#writing-to-files),
    [`image.getBase64(mime, cb)`](https://github.com/oliver-moran/jimp#data-uri), etc.
    Extended to add image.writeAsync, image.getBase64Async.
  ###
  @format: (str, opts) ->

  ###
  Given a shell command, execute the command, then format into an image using {sh2png.format}.

  @example Run Mocha, and write output to file using JavaScript callbacks
    sh2png = require("sh2png")
    sh2png
      .run("mocha")
      .then(function(img) {
        img.write(__dirname+"/output.png", function() {
          console.log("Mocha output written to output.png");
        });
      });

  @example Run Mocha, and get Base64'd output using Promisified methods and CoffeeScript
    sh2png = require "sh2png"
    sh2png
      .run "mocha"
      .then (img) -> img.getBase64Async "image/png"
      .then (base64) ->
        console.log "Base64'd Mocha output: #{base64}"

  @param {String} cmd the shell command to run
  @param {Object} opts options to configure running the given command and formatting the image.
  @option opts {Number} width the console width to wrap characters at.  Defaults to 80 characters
  @option opts {Object} exec options passed to NodeJS's
    [`exec`](https://nodejs.org/api/child_process.html#child_process_child_process_exec_command_options_callback)
  @option opts {String} font a path to a BMF font to use when drawing the image.  Defaults to Ubuntu Mono, included in
    `sh2png`
  @return {Promise<Image>} a [JIMP](https://github.com/oliver-moran/jimp) image, which supports
    [`image.write(path, cb)`](https://github.com/oliver-moran/jimp#writing-to-files),
    [`image.getBase64(mime, cb)`](https://github.com/oliver-moran/jimp#data-uri), etc.
    Extended to add image.writeAsync, image.getBase64Async.
  ###
  exec: (cmd, opts) ->

module.exports = sh2png
