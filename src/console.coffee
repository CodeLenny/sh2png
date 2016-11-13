#!/usr/bin/env node

Promise = require "bluebird"
fs = Promise.promisifyAll require "fs"
pkg = require "../package"
sh2png = require "./sh2png"
colorNames = ["default", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]

program = require "commander"

program
  .version pkg.version

# Collect arguments into an array.
collect = (val, memo) ->
  memo ?= []
  memo.push val
  memo

# Parse RGBA values
parseRGBA = (val) ->
  switch
    when val.indexOf("0x") is 0
      parseInt val, 16
    when val.indexOf(",") > -1 and (colors = val.split ",").length > 2
      colors = val.split ","
      out = []
      for v, i in ["r", "g", "b", "a"]
        if v is "a" and not colors[i]
          colors[i] = "FF"
        colors[i] = parseInt colors[i], 16
        unless 0 <= colors[i] <= 255
          throw "RGBA component #{v} must be between 0 and 255, given #{colors[i]} in color #{val}"
      [r,g,b,a] = colors
      return (1 << 34) + (r << 24) + (g << 16) + (b << 8) + a
    else
      throw "Misformatted color #{val}.  Try providing in the format 0xRRGGBBAA or RR,GG,BB[,AA]."

# Given the name of a color, output the name in it's own color.
doColor = (color, bold=yes) ->
  code = null
  for own c, n of sh2png.colorCodes when n is color
    code = c
  return color unless color and code
  b = if bold then "\x1b[1m" else ""
  "#{b}\x1b[#{code}m#{color}\x1b[0m"

###
Convert raw options into supported options by sh2png, including converting colors from flat options into an object.
###
parseOpts = (options) ->
  for opt, val of options
    switch
      when opt is "background"
        options.colors ?= {}
        options.colors.background = val
        delete options.background
      when opt.indexOf("bold") is 0
        name = opt.replace("bold", "").toLowerCase()
        options.colors ?= {}
        options.colors.bold ?= {}
        options.colors.bold[name] = val
        delete options[opt]
      when opt in colorNames
        options.colors ?= {}
        options.colors.normal ?= {}
        options.colors.normal[opt] = val
        delete options[opt]
  options

###
@return {Promise<String>} all stdin input as a utf8 string.
###
getStdin = ->
  process.stdin.setEncoding "utf8"
  new Promise (resolve, reject) ->
    data = ""
    process.stdin.on "readable", ->
      while chunk = process.stdin.read()
        data += chunk
    process.stdin.on "end", ->
      resolve data

# All commands take sh2png.format options.
cols = process.stdout.columns
program.option "-w, --width <n>", "The console width.  Defaults to terminal width (#{cols})", parseInt, cols
program.option "--font <path>",
  "A path to a BMFont file to use.  Can be used more than once.  Defaults to Ubuntu Mono, 16pt.",
  collect, null
  
# All commands take arguments only valid on the console.
program.option "-f, --format <format>",
  "File format to output.  Valid options: png, jpeg, bmp.  Defaults to extension of filename if given, otherwise 'png'"
program.option "-o, --output <file>", "Path to store the output file.  If not given, outputs to stdout."
program.option "--base64",
  "Output a base64 encoded image, instead of a binary file.  Explicit output format is required."
for color in colorNames
  normal = sh2png.colorScheme.normal[color]
  bold = sh2png.colorScheme.bold[color]
  program.option "--#{color} <hex>",
    "Set the output color for #{doColor color, no} text.  RGBA value.  Default: 0x#{normal.toString(16).toUpperCase()}",
    parseRGBA, normal
  program.option "--bold-#{color} <hex>",
    "Set the output color for bold #{doColor color} text.  RGBA value.  Default: 0x#{bold.toString(16).toUpperCase()}",
    parseRGBA, bold
background = sh2png.colorScheme.background
program.option "--background",
  "Set the background color.  RGBA value.  Default: 0x#{background.toString(16).toUpperCase()}",
  parseRGBA, background

program
  .command "format", "Format text piped into the command"
  .action (options) ->
    options = {} unless options and options isnt "-"
    options = parseOpts options
    getStdin()
      .then (stdin) ->
        sh2png.format stdin, options
      .then (image) ->
        if options.base64
          mime = if options.format then "image/#{options.format}" else "image/png"
          base64 = image.getBase64 mime
          if options.output
            return fs.writeFileAsync options.output, base64
          else
            return console.log base64
        else
          if options.output
            return image.write options.output
          else
            mime = if options.format then "image/#{options.format}" else "image/png"
            new Promise (resolve, reject) ->
              image.getBuffer mime, (err, buffer) ->
                process.stdout.write buffer
                resolve()
      .then ->
        if options.output
          console.log "Wrote #{options.output}."

program.parse process.argv