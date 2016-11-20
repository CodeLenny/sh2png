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
          throw new RangeError "RGBA component #{v} must be between 0 and 255, given #{colors[i]} in color #{val}"
      [r,g,b,a] = colors
      return (1 << 34) + (r << 24) + (g << 16) + (b << 8) + a
    else
      throw new RangeError "Misformatted color #{val}.  Try providing in the format 0xRRGGBBAA or RR,GG,BB[,AA]."

# Ensure that input is one of the provided values
oneOf = (option, options...) ->
  (input) ->
    return input if input in options
    if input and input.length > 1
      throw new RangeError "Invalid option '#{input}' for #{option}.  Must be one of #{options.join ", "}"
    throw new RangeError "Missing input for option '#{option}'.  Must be one of #{options.join ", "}"

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
  output = {}
  internal = ["commands", "options", "Command", "Option", "executables", "rawArgs", "args", "domain"]
  for opt, val of options
    switch
      when opt is "background"
        output.colors ?= {}
        output.colors.background = val
      when opt.indexOf("bold") is 0
        name = opt.replace("bold", "").toLowerCase()
        output.colors ?= {}
        output.colors.bold ?= {}
        output.colors.bold[name] = val
      when opt in colorNames
        output.colors ?= {}
        output.colors.normal ?= {}
        output.colors.normal[opt] = val
      when opt not in internal and opt.indexOf("_") isnt 0 and typeof val isnt "function"
        output[opt] = val
  output

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
  "File format to output.  Valid options: png, jpeg, bmp.  Defaults to extension of filename if given, otherwise 'png'",
  oneOf("format", "png", "jpg", "bmp"), "png"
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
  .command "piped"
  .alias "-"
  .description "Format text piped into the command"
  .action (opts) ->
    options = parseOpts program
    # Replace `promise` with any prerequisite actions to be run before formatting
    promise = Promise.resolve()
    promise
      .then ->
        getStdin()
      .then (stdin) ->
        sh2png.format stdin, options
      .then (image) ->
        if options.base64
          options.format = "jpeg" if options.format and options.format is "jpg"
          mime = if options.format then "image/#{options.format}" else "image/png"
          return image
            .getBase64Async mime
            .then (base64) ->
              if options.output
                return fs.writeFileAsync options.output, base64
              else
                return console.log base64
        else
          if options.output
            return image.write options.output
          else
            options.format = "jpeg" if options.format and options.format is "jpg"
            mime = if options.format then "image/#{options.format}" else "image/png"
            new Promise (resolve, reject) ->
              image.getBuffer mime, (err, buffer) ->
                return reject err if err
                process.stdout.write buffer
                resolve()
      .then ->
        if options.output
          console.log "Wrote #{options.output}."
      .catch (err) ->
        console.error "Error while formatting input."
        console.error err

program.parse process.argv
