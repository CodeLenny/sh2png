Promise = require "bluebird"
Jimp = require "@codelenny/jimp"

class sh2png
  
  ###
  @property {Object} the default color scheme for coloring messages.
  Default colors from https://github.com/Mayccoll/Gogh/blob/master/themes/one.dark.sh
  ###
  @colorScheme =
    normal:
      default: 0x5C6370FF
      black: 0x000000FF
      red: 0xE06C75FF
      green: 0x98C379FF
      yellow: 0xD19A66FF
      blue: 0x61AFEFFF
      magenta: 0xC678DDFF
      cyan: 0x56B6C2FF
      white: 0xABB2BFFF
    bold:
      default: 0x5C6370FF
      black: 0x5C6370FF
      red: 0xE06C75FF
      green: 0x98C379FF
      yellow: 0xD19A66FF
      blue: 0x61AFEFFF
      magenta: 0xC678DDFF
      cyan: 0x56B6C2FF
      white: 0xFFFEFEFF
    background: 0x1E2127FF
  
  @colorCodes =
    "39": "default"
    "30": "black"
    "31": "red"
    "32": "green"
    "33": "yellow"
    "34": "blue"
    "35": "magenta"
    "36": "cyan"
    "37": "white"

  ###
  Returns the required height and width of the image.
  @param {String} str the console output that will be formatted
  @param {Object} opts the user-supplied options.  See {sh2png.format}
  @return {Promise<Array<Number>>} the needed [height, width] of the image, in pixels.
  @private
  ###
  @getImageDimensions = (str, opts) ->
    load = Promise.promisify require "@codelenny/load-bmfont"
    f = opts.fonts
    f = f[0] if Array.isArray f
    load f
      .then (font) ->
        height = str.split("\n").length * font.common.lineHeight
        # get the character "m" (ASCII 115) to determine width
        m = null
        fallback = null
        for char in font.chars
          if char.id is 115
            m = char
            break
          unless fallback
            if char.width and char.xadvance and char.xoffset
              fallback = char
        m ?= fallback
        unless m
          throw new Error("Couldn't find a valid character in the font given.")
        charWidth = Math.max m.xadvance, m.width + m.xoffset
        width = (opts.width * charWidth) + 1
        [height, width]

  ###
  Create an empty JIMP Image to write the console output into.
  @param {String} str the console output that will be formatted
  @param {Object} opts the user-supplied options.  See {sh2png.format}
  @return {Promise<Image>} a JIMP image, promisified
  @private
  ###
  @createCanvas = (str, opts) ->
    @getImageDimensions str, opts
      .then ([height, width]) ->
        new Promise (resolve, reject) ->
          new Jimp width, height, opts.colors.background, (err, image) ->
            reject err if err
            resolve Promise.promisifyAll image

  ###
  Split the given console output into functions that can draw each formatted section of the output on an image.
  @param {String} str the console output that will be formatted
  @param {Object} opts the user-supplied options.  See {sh2png.format}
  @return {Promise<Array<Function>>} An array of functions, each drawing a section of the console output on an image.
    Functions take `font`, `image`, and `opts`, and return a Promise.
  @private
  ###
  @splitString = (str, opts) ->
    colorCode = /(?:(?:\\(?:e|033|x1b))|\x1b)\[([0-9]+);?([0-9]+)?m/
    color = @parseColor null, '39', null, opts
    line = 0
    char = 0
    all = []
    while str.length > 0
      br = str.indexOf "\n"
      escape = str.search colorCode
      if escape is -1 and br is -1
        all.push @drawString str, color, line, char
        break
      if br > -1 and (escape is -1 or br < escape)
        all.push @drawString str.substr(0, br), color, line, char
        char = 0
        line = line + 1
        str = str.substr br + 1
        continue
      if escape > 0
        all.push @drawString str.substr(0, escape), color, line, char
      char += escape
      [sequence, code1, code2] = str.match colorCode
      color = @parseColor color, code1, code2, opts
      str = str.substr(escape + sequence.length)
    Promise.resolve all

  ###
  Return a draw function that takes `font`, `image`, `opts`, and draw the specified string with the given color, line,
  and character onto the image with the given font.
  @param {String} str the text to print
  @param {Object} color the color to use when printing the string
  @param {Number} line the given vertical line to draw the text at
  @param {Number} char the given horizontal column to draw the text at
  @return {Function<Promise>} a function that returns a promise to draw the text with the given details.
  @private
  ###
  @drawString = (str, color, line, char) ->
    (fonts, image, opts) ->
      font = fonts
      font = fonts[0] if Array.isArray fonts
      unless font.common.charWidth
        if font.chars.m?.xadvance
          font.common.charWidth = font.chars.m.xadvance
          # from jimp: font.chars.m.xoffset + (font.chars.m.xadvance ? 0)
        else if font.chars[firstChar = Object.keys(font.chars)[0]]?.xadvance
          font.common.charWidth = font.chars[firstChar].xadvance
        else
          throw new Error("Couldn't find any characters in the font given")
      c = opts.colors[if color.bold then "bold" else "normal"][color.color]
      image.print fonts, char * font.common.charWidth, line * font.common.lineHeight, str, {color: c}
      Promise.resolve()

  ###
  Determine the color of the output text, given the previous color and an escape code.
  @param {Object} color the previous color
  @param {String} code1 an escape code number (a.k.a. 39 for escape `\e[39m`, default color)
  @param {String} code2 an escape code number (a.k.a. 39 for escape `\e[39m`, default color)
  @param {Object} opts the user-supplied options.  See {sh2png.format}
  @private
  ###
  @parseColor = (color={}, code1, code2, opts) ->
    for code in [code1, code2] when code
      switch
        when code is '0'
          color = {color: "default", bold: no}
        when code is '1'
          color = {color: color.color ? "default", bold: yes}
        when code is '21'
          color = {color: color.color ? "default", bold: no}
        when @colorCodes[code]
          color = {color: @colorCodes[code], bold: color.bold ? no}
    color

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
  @option opts {Number} width the console width to wrap characters at.  Defaults to the longest line in the string.
  @option opts {String, Array<String>} font a path (or array of paths) to a BMF font to use when drawing the image.
    Defaults to Ubuntu Mono 10pt, included in `sh2png`.
  @option opts {Object} colors a color scheme to apply when formatting messages.  Colors must be native JavaScript rgba
    hex values including transparency, such as `0x0x5C6370FF`.  Structure: `{normal: {}, bold: {}, background}`, with
    colors `default`, `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white` under `normal` and `bold`.
    Defaults to using a theme based on [Atom One Dark](https://github.com/Mayccoll/Gogh/blob/master/themes/one.dark.sh).
  @return {Promise<Image>} a [JIMP](https://github.com/oliver-moran/jimp) image, which supports
    [`image.write(path, cb)`](https://github.com/oliver-moran/jimp#writing-to-files),
    [`image.getBase64(mime, cb)`](https://github.com/oliver-moran/jimp#data-uri), etc.
    Extended to add image.writeAsync, image.getBase64Async.
  ###
  @format: (str, opts={}) ->
    opts.fonts ?= "#{__dirname}/../font/Ubuntu_Mono_16pt.fnt"
    opts.width ?= Math.max str.split("\n").map((l) -> l.length)...
    opts.colors ?= @colorScheme
    opts.colors.normal ?= {}
    opts.colors.bold ?= {}
    for color in ["default", "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]
      opts.colors.normal[color] ?= @colorScheme.normal[color]
      opts.colors.bold[color] ?= @colorScheme.bold[color]
    opts.colors.background ?= @colorScheme.background
    fonts = null
    image = null
    if Array.isArray opts.fonts
      fonts = Promise.map opts.fonts, (font) -> Jimp.loadFont font
    else
      fonts = Jimp.loadFont opts.fonts
    Promise.join fonts, @createCanvas(str, opts), @splitString(str, opts)
      .then ([f, i, split]) ->
        font = f
        image = i
        all = []
        for fn in split
          all.push fn(font, image, opts)
        Promise.all all
      .then ->
        image

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
  @option opts {String} font a path to a BMF font to use when drawing the image.  Defaults to Ubuntu Mono 10pt, included
    in `sh2png`.
  @return {Promise<Image>} a [JIMP](https://github.com/oliver-moran/jimp) image, which supports
    [`image.write(path, cb)`](https://github.com/oliver-moran/jimp#writing-to-files),
    [`image.getBase64(mime, cb)`](https://github.com/oliver-moran/jimp#data-uri), etc.
    Extended to add image.writeAsync, image.getBase64Async.
  ###
  exec: (cmd, opts={}) ->

module.exports = sh2png
