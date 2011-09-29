assert = require 'assert'
colorspaces = require './colorspaces.js'

# http://www.brucelindbloom.com/index.html?ColorCalculator.html
colors =
  indigo: # 75, 0, 130
    'sRGB': [0.29412, 0.00000, 0.50980]
    'CIEXYZ': [0.06931, 0.03108, 0.21354]
    'CIExyY': [0.22079, 0.09899, 0.03108]
    'CIELAB': [20.470, 51.695, -53.320]
    'CIELCH': [20.470, 74.265, 314.113]
  crimson: # 220, 20, 60
    'sRGB': [0.86275, 0.07843, 0.23529]
    'CIEXYZ': [0.30581, 0.16042, 0.05760]
    'CIExyY': [0.58380, 0.30625, 0.16042]
    'CIELAB': [47.030, 70.936, 33.595]
    'CIELCH': [47.030, 78.489, 25.342]
  white: # 255, 255, 255
    'sRGB': [1, 1, 1]
    'CIEXYZ': [0.95050, 1.00000, 1.08900]
    'CIExyY': [0.31272, 0.32900, 1]
    'CIELAB': [100, 0.005, -0.010]
    # CIELCH omitted because Hue is almost completely
    # irrelevant for white and its big rounding error
    # is acceptable here. Hue is better tested with 
    # more saturated colors, like the two above
  black: # 0, 0, 0
    'sRGB': [0, 0, 0]
    'CIEXYZ': [0, 0, 0]
    'CIExyY': [0, 0, 0]
    'CIELAB': [0, 0, 0]
    # CIELCH omitted

permissible_error =
  'CIELAB': 0.01
  'CIEXYZ': 0.001
  'CIExyY': 0.001
  'CIELCH': 0.01
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
      color = colorspaces.get_color(space1, tuple1)
      # Convert each of those to every color space and compare
      for space2, tuple2 of definitions
        output = color.as(space2)
        for val in output
          assert.ok not isNaN(val), "\n
            NaN returned when converting from #{space1} to #{space2}\n
            #{output}\n"
        dif = big_dif tuple2, output
        # If the biggest difference is too big, complain
        assert.ok dif <= permissible_error[space2], "\n
          Big error when converting from #{space1} to #{space2}\n
          Input: #{tuple1}\n
          Output: #{output}\n
          Should be: #{tuple2}\n"

