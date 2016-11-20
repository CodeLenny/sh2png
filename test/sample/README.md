# test/sample/

Sample outputs are included, and can be compared against dynamic outputs in `test/output/`.
Commits to this folder need to be manually reviewed, to ensure that images look like they should.

In addition, each image must be listed in this README, describing what test creates it.

## Images

- `oneliner.png`
  is created by [test-format-plain][../test-format-plain.coffee].
  It contains a single line of unformatted text, for very quick testing.
- `block.png`
  is created by [test-format-plain][../test-format-plain.coffee].
  It contains three lines of textual output, with no coloring.
- `simple-color-normal-{default,black,red,green,yellow,blue,magenta,cyan,white}.png`
  are created by [test-colors][../test-colors.coffee].
  Each image contains the name of it's color, in it's own color.
- `missing-character-default-font.png`
  is created by [test-custom-font][../test-custom-font.coffee].
  It demonstrates what is outputted if a character is drawn that doesn't exist in the given font.
- `missing-character-custom-font.png`
  is created by [test-custom-font][../test-custom-font.coffee].
  It demonstrates using a custom font to draw a character not in the default font.
- `missing-character-fallback-font.png`
  is created by [test-custom-font][../test-custom-font.coffee].
  It demonstrates using multiple fonts to create a string using characters found in each of the font files, but not both.

### CLI

- `console-format-stdout.png`
  is created by [test-pipe-format][../test-pipe-format.coffee].
  It tests the core usage of `sh2png piped` by piping `sh2png --help` and styling the output.
- `console-format-stdout-alias.png`
  is created by [test-pipe-format][../test-pipe-format.coffee].
  It tests that `sh2png -` (an alias of `sh2png piped`) styles text.