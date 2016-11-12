// Generated by CoffeeScript 1.11.1
(function() {
  var Promise, background, bold, collect, color, colorNames, cols, doColor, fs, getStdin, j, len, normal, parseOpts, parseRGBA, pkg, program, sh2png,
    hasProp = {}.hasOwnProperty,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Promise = require("bluebird");

  fs = Promise.promisifyAll(require("fs"));

  pkg = require("../package");

  sh2png = require("./sh2png");

  colorNames = ["default", "red", "green", "yellow", "blue", "magenta", "cyan", "white"];

  program = require("commander");

  program.version(pkg.version);

  collect = function(val, memo) {
    if (memo == null) {
      memo = [];
    }
    memo.push(val);
    return memo;
  };

  parseRGBA = function(val) {
    var a, b, colors, g, i, j, len, out, r, ref, ref1, v;
    switch (false) {
      case val.indexOf("0x") !== 0:
        return parseInt(val, 16);
      case !(val.indexOf(",") > -1 && (colors = val.split(",")).length > 2):
        colors = val.split(",");
        out = [];
        ref = ["r", "g", "b", "a"];
        for (i = j = 0, len = ref.length; j < len; i = ++j) {
          v = ref[i];
          if (v === "a" && !colors[i]) {
            colors[i] = "FF";
          }
          colors[i] = parseInt(colors[i], 16);
          if (!((0 <= (ref1 = colors[i]) && ref1 <= 255))) {
            throw "RGBA component " + v + " must be between 0 and 255, given " + colors[i] + " in color " + val;
          }
        }
        r = colors[0], g = colors[1], b = colors[2], a = colors[3];
        return (1 << 34) + (r << 24) + (g << 16) + (b << 8) + a;
      default:
        throw "Misformatted color " + val + ".  Try providing in the format 0xRRGGBBAA or RR,GG,BB[,AA].";
    }
  };

  doColor = function(color, bold) {
    var b, c, code, n, ref;
    if (bold == null) {
      bold = true;
    }
    code = null;
    ref = sh2png.colorCodes;
    for (c in ref) {
      if (!hasProp.call(ref, c)) continue;
      n = ref[c];
      if (n === color) {
        code = c;
      }
    }
    if (!(color && code)) {
      return color;
    }
    b = bold ? "\x1b[1m" : "";
    return b + "\x1b[" + code + "m" + color + "\x1b[0m";
  };


  /*
  Convert raw options into supported options by sh2png, including converting colors from flat options into an object.
   */

  parseOpts = function(options) {
    var base, base1, name, opt, val;
    for (opt in options) {
      val = options[opt];
      switch (false) {
        case opt !== "background":
          if (options.colors == null) {
            options.colors = {};
          }
          options.colors.background = val;
          delete options.background;
          break;
        case opt.indexOf("bold") !== 0:
          name = opt.replace("bold", "").toLowerCase();
          if (options.colors == null) {
            options.colors = {};
          }
          if ((base = options.colors).bold == null) {
            base.bold = {};
          }
          options.colors.bold[name] = val;
          delete options[opt];
          break;
        case indexOf.call(colorNames, opt) < 0:
          if (options.colors == null) {
            options.colors = {};
          }
          if ((base1 = options.colors).normal == null) {
            base1.normal = {};
          }
          options.colors.normal[opt] = val;
          delete options[opt];
      }
    }
    return options;
  };


  /*
  @return {Promise<String>} all stdin input as a utf8 string.
   */

  getStdin = function() {
    process.stdin.setEncoding("utf8");
    return new Promise(function(resolve, reject) {
      var data;
      data = "";
      process.stdin.on("readable", function() {
        var chunk, results;
        results = [];
        while (chunk = process.stdin.read()) {
          results.push(data += chunk);
        }
        return results;
      });
      return process.stdin.on("end", function() {
        return resolve(data);
      });
    });
  };

  cols = process.stdout.columns;

  program.option("-w, --width <n>", "The console width.  Defaults to terminal width (" + cols + ")", parseInt, cols);

  program.option("--font <path>", "A path to a BMFont file to use.  Can be used more than once.  Defaults to Ubuntu Mono, 16pt.", collect, null);

  program.option("-f, --format <format>", "File format to output.  Valid options: png, jpeg, bmp.  Defaults to extension of filename if given, otherwise 'png'");

  program.option("-o, --output <file>", "Path to store the output file.  If not given, outputs to stdout.");

  program.option("--base64", "Output a base64 encoded image, instead of a binary file.  Explicit output format is required.");

  for (j = 0, len = colorNames.length; j < len; j++) {
    color = colorNames[j];
    normal = sh2png.colorScheme.normal[color];
    bold = sh2png.colorScheme.bold[color];
    program.option("--" + color + " <hex>", "Set the output color for " + (doColor(color, false)) + " text.  RGBA value.  Default: 0x" + (normal.toString(16).toUpperCase()), parseRGBA, normal);
    program.option("--bold-" + color + " <hex>", "Set the output color for bold " + (doColor(color)) + " text.  RGBA value.  Default: 0x" + (bold.toString(16).toUpperCase()), parseRGBA, bold);
  }

  background = sh2png.colorScheme.background;

  program.option("--background", "Set the background color.  RGBA value.  Default: 0x" + (background.toString(16).toUpperCase()), parseRGBA, background);

  program.command("format", "Format text piped into the command").alias("-").action(function(options) {
    options = parseOpts(options);
    return getStdin().then(function(stdin) {
      return sh2png.format(stdin, options);
    }).then(function(image) {
      var base64, mime;
      if (options.base64) {
        mime = options.format ? "image/" + options.format : "image/png";
        base64 = image.getBase64(mime);
        if (options.output) {
          return fs.writeFileAsync(options.output, base64);
        } else {
          return console.log(base64);
        }
      } else {
        if (options.output) {
          return image.write(options.output);
        } else {
          mime = options.format ? "image/" + options.format : "image/png";
          return new Promise(function(resolve, reject) {
            return image.getBuffer(mime, function(err, buffer) {
              process.stdout.write(buffer);
              return resolve();
            });
          });
        }
      }
    }).then(function() {
      if (options.output) {
        return console.log("Wrote " + options.output + ".");
      }
    });
  });

  program.parse(process.argv);

}).call(this);
