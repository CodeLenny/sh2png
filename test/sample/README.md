# test/sample/

Sample outputs are included, and can be compared against dynamic outputs in `test/output/`.
Commits to this folder need to be manually reviewed, to ensure that images look like they should.

In addition, each image must be listed in this README, describing what test creates it.

## Images

- `oneliner.png`
  is created by [test-format-plain].
  It contains a single line of unformatted text, for very quick testing.
- `block.png`
  is created by [test-format-plain].
  It contains three lines of textual output, with no coloring.
- `simple-color-normal-{default,black,red,green,yellow,blue,magenta,cyan,white}.png`
  are created by [test-colors].
  Each image contains the name of it's color, in it's own color.
- `missing-character-default-font.png`
  is created by [test-custom-font].
  It demonstrates what is outputted if a character is drawn that doesn't exist in the given font.
- `missing-character-custom-font.png`
  is created by [test-custom-font].
  It demonstrates using a custom font to draw a character not in the default font.
- `missing-character-fallback-font.png`
  is created by [test-custom-font].
  It demonstrates using multiple fonts to create a string using characters found in each of the font files, but not both.

### CLI

- `console-format-stdout.png`
  is created by [test-pipe-format].
  It tests the core usage of `sh2png piped` by piping `sh2png --help` and styling the output.
- `console-format-stdout-alias.png`
  is created by [test-pipe-format].
  It tests that `sh2png -` (an alias of `sh2png piped`) styles text.
- `console-format-stdout-format.{format=png,jpg,bmp}`
  is created by [test-pipe-format].
  It tests that `sh2png --format {format} -` outputs a file of the correct type.
- `console-format-output.{format=png,jpg,bmp}`
  is created by [test-pipe-format].
  It tests that `sh2png --output output.{format} -` outputs a file of the correct type.
- `console-format-base64.{format=png,jpg,bmp}[-64]`
  are created by [test-pipe-format].
  It runs `sh2png --format {format} --base64 -`, and pipes into `.{format}-64`.
  Then the base64 encoded file is decoded into `.{format}`.
- `console-format-output-base64.{format=png,jpg,bmp}[-64]`
  are created by [test-pipe-format].
  It runs `sh2png --format {format} --base64 -`, and pipes into `.{format}-64`.
  Then the base64 encoded file is decoded into `.{format}`.
- `console-format-red-rgba.png`
  is created by [test-pipe-format].
  It changes the color defined for red text as green (`--red 0,FF,0`), and makes sure that the outputted image has the
  correct color.
- `console-format-red-hex.png`
  is created by [test-pipe-format].
  It changes the color defined for red text as green (`--red 0x00FF00FF`), and makes sure that the outputted image has
  the correct color.
  
  [test-pipe-format]: ../test-pipe-format.coffee
  [test-custom-font]: ../test-custom-font.coffee
  [test-format-plain]: ../test-format-plain.coffee
  [test-colors]: ../test-colors.coffee
