assert = require 'assert'
colorspaces = require './colorspaces.js'

colors =
  indigo:
    'hex': '#4b0082'
    'sRGB': [0.29412, 0.00000, 0.50980]
    'CIEXYZ': [0.06931, 0.03108, 0.21354]
    'CIExyY': [0.22079, 0.09899, 0.03108]
    'CIELAB': [20.470, 51.695, -53.320]
    'CIELCH': [20.470, 74.265, 314.113]
    'CIELUV': [20.470, 10.084, -61.343]
  crimson:
    'hex': '#dc143c'
    'sRGB': [0.86275, 0.07843, 0.23529]
    'CIEXYZ': [0.30581, 0.16042, 0.05760]
    'CIExyY': [0.58380, 0.30625, 0.16042]
    'CIELAB': [47.030, 70.936, 33.595]
    'CIELCH': [47.030, 78.489, 25.342]
    'CIELUV': [47.030, 138.278, 19.641]
  white:
    'hex': '#ffffff'
    'sRGB': [1, 1, 1]
    'CIEXYZ': [0.95050, 1.00000, 1.08900]
    'CIExyY': [0.31272, 0.32900, 1]
    'CIELAB': [100, 0.005, -0.010]
    'CIELUV': [100, 0.001, -0.017]
    # CIELCH omitted because Hue is almost completely
    # irrelevant for white and its big rounding error
    # is acceptable here. Hue is better tested with 
    # more saturated colors, like the two above
  black:
    'hex': '#000000'
    'sRGB': [0, 0, 0]
    'CIEXYZ': [0, 0, 0]
    'CIExyY': [0, 0, 0]
    'CIELAB': [0, 0, 0]
    'CIELUV': [0, 0, 0]
    # CIELCH omitted

permissible_error =
  'CIELAB': 0.01
  'CIEXYZ': 0.001
  'CIExyY': 0.001
  'CIELCH': 0.01
  'CIELUV': 0.01
  'sRGB': 0.001

# Returns the biggest difference factor between two corresponding
# elements in two tuples
big_dif = (tuple1, tuple2) ->
  ret = 0
  for i in [0..tuple1.length - 1]
    dif = Math.abs(tuple1[i] - tuple2[i])
    ret = dif if dif > ret
  return ret

# For every test color
for name, definitions of colors
  console.log "Testing " + name
  # Make a color object for every definition of the test color
  for space1, tuple1 of definitions
    # Convert each of those to every color space and compare
    for space2, tuple2 of definitions
      output = colorspaces.converter(space1, space2)(tuple1)
      # If the target space is hex, simply compare the two for equality
      if space2 is 'hex'
        assert.ok output is tuple2, "\n
          Error when converting #{space1} to hex\n"
        continue
      # Otherwise first make sure there are no NaNs
      for val in output
        assert.ok not isNaN(val), "\n
          NaN returned when converting from #{space1} to #{space2}\n
          #{output}\n"
      # Then calculate the biggest difference
      dif = big_dif tuple2, output
      # ... and see if it's too big
      assert.ok dif <= permissible_error[space2], "\n
        Big error when converting from #{space1} to #{space2}\n
        Input: #{tuple1}\n
        Output: #{output}\n
        Should be: #{tuple2}\n"

# .use(colorspaces) doesn't seem to work. Stylus doesn't throw
# an error. For now refer to tests.styl to test Stylus support.
# Eventually I want to test it programmatically

"
try
  stylus = require 'stylus'
if stylus?
  stylus(styl).use(colorspaces).render (err, css) ->
    throw err if err
    console.log css
"

