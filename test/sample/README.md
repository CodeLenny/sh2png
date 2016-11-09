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
