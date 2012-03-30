# All Math on this page comes from http://www.easyrgb.com
dot_product = (a, b) ->
  ret = 0
  for i in [0..a.length-1]
    ret += a[i] * b[i]
  return ret

# Rounds number to a given number of decimal places
round = (num, places) ->
  m = Math.pow 10, places
  return Math.round(num * m) / m

# Returns whether given color coordinates fit within their valid range
within_range = (vector, ranges) ->
  # Round to three decimal places to avoid rounding errors
  # e.g. R_rgb = -0.0000000001
  vector = (round(n, 3) for n in vector)
  for i in [0..vector.length - 1]
    if vector[i] < ranges[i][0] or vector[i] > ranges[i][1]
      return false
  return true

# The D65 standard illuminant
ref_X = 0.95047
ref_Y = 1.00000
ref_Z = 1.08883
ref_U = (4 * ref_X) / (ref_X + (15 * ref_Y) + (3 * ref_Z))
ref_V = (9 * ref_Y) / (ref_X + (15 * ref_Y) + (3 * ref_Z))

# CIE L*a*b* constants
lab_e = 0.008856
lab_k = 903.3

# Used for Lab and Luv conversions
f = (t) ->
  if t > lab_e
    Math.pow(t, 1 / 3)
  else
    7.787 * t + 16 / 116
f_inv = (t) ->
  if Math.pow(t, 3) > lab_e
    Math.pow(t, 3)
  else
    (116 * t - 16) / lab_k

# This map will contain our conversion functions
# conv[from][to] = (tuple) -> ...
conv =
  'CIEXYZ': {}
  'CIExyY': {}
  'CIELAB': {}
  'CIELCH': {}
  'CIELUV': {}
  'CIELCHuv': {}
  'sRGB': {}
  'hex': {}

conv['CIEXYZ']['sRGB'] = (tuple) ->
  m = [
    [3.2406, -1.5372, -0.4986]
    [-0.9689, 1.8758,  0.0415]
    [0.0557, -0.2040,  1.0570]
  ]
  from_linear = (c) ->
    a = 0.055
    if c <= 0.0031308
      12.92 * c
    else
      1.055 * Math.pow(c, 1 / 2.4) - 0.055
  _R = from_linear dot_product m[0], tuple
  _G = from_linear dot_product m[1], tuple
  _B = from_linear dot_product m[2], tuple
  return [_R, _G, _B]

conv['sRGB']['CIEXYZ'] = (tuple) ->
  [_R, _G, _B] = tuple
  to_linear = (c) ->
    a = 0.055
    if c > 0.04045
      Math.pow (c + a) / (1 + a), 2.4
    else
      c / 12.92
  m = [
    [0.4124, 0.3576, 0.1805]
    [0.2126, 0.7152, 0.0722]
    [0.0193, 0.1192, 0.9505]
  ]
  rgbl = [to_linear(_R), to_linear(_G), to_linear(_B)]
  _X = dot_product m[0], rgbl
  _Y = dot_product m[1], rgbl
  _Z = dot_product m[2], rgbl
  [_X, _Y, _Z]

conv['CIEXYZ']['CIExyY'] = (tuple) ->
  [_X, _Y, _Z] = tuple
  sum = _X + _Y + _Z
  if sum is 0
    return [0, 0, _Y]
  [_X / sum, _Y / sum, _Y]

conv['CIExyY']['CIEXYZ'] = (tuple) ->
  [_x, _y, _Y] = tuple
  if _y is 0
    return [0, 0, 0]
  _X = _x * _Y / _y
  _Z = (1 - _x - _y) * _Y / _y
  [_X, _Y, _Z]

conv['CIEXYZ']['CIELAB'] = (tuple) ->
  [_X, _Y, _Z] = tuple
  fx = f _X / ref_X
  fy = f _Y / ref_Y
  fz = f _Z / ref_Z
  _L = 116 * fy - 16
  _a = 500 * (fx - fy)
  _b = 200 * (fy - fz)
  [_L, _a, _b]

conv['CIELAB']['CIEXYZ'] = (tuple) ->
  [_L, _a, _b] = tuple
  var_y = (_L + 16) / 116
  var_z = var_y - _b / 200
  var_x = _a / 500 + var_y
  _X = ref_X * f_inv(var_x)
  _Y = ref_Y * f_inv(var_y)
  _Z = ref_Z * f_inv(var_z)
  [_X, _Y, _Z]

conv['CIEXYZ']['CIELUV'] = (tuple) ->
  [_X, _Y, _Z] = tuple
  var_U = (4 * _X) / (_X + (15 * _Y) + (3 * _Z))
  var_V = (9 * _Y) / (_X + (15 * _Y) + (3 * _Z))
  _L = 116 * f(_Y / ref_Y) - 16
  # Black will create a divide-by-zero error
  if _L is 0
    return [0, 0, 0]
  _U = 13 * _L * (var_U - ref_U)
  _V = 13 * _L * (var_V - ref_V)
  [_L, _U, _V]

conv['CIELUV']['CIEXYZ'] = (tuple) ->
  [_L, _U, _V] = tuple
  # Black will create a divide-by-zero error
  if _L is 0
    return [0, 0, 0]
  var_Y = f_inv (_L + 16) / 116
  var_U = _U / (13 * _L) + ref_U
  var_V = _V / (13 * _L) + ref_V
  _Y = var_Y * ref_Y
  _X = 0 - (9 * _Y * var_U) / ((var_U - 4) * var_V - var_U * var_V)
  _Z = (9 * _Y - (15 * var_V * _Y) - (var_V * _X)) / (3 * var_V)
  [_X, _Y, _Z]

scalar_to_polar = (tuple) ->
  [_L, var1, var2] = tuple
  _C = Math.pow Math.pow(var1, 2) + Math.pow(var2, 2), 1 / 2
  _h_rad = Math.atan2 var2, var1
  _h = _h_rad * 360 / 2 / Math.PI
  _h = 360 + _h if _h < 0
  [_L, _C, _h]
conv['CIELAB']['CIELCH'] = scalar_to_polar
conv['CIELUV']['CIELCHuv'] = scalar_to_polar

polar_to_scalar = (tuple) ->
  [_L, _C, _h] = tuple
  _h_rad = _h / 360 * 2 * Math.PI
  var1 = Math.cos(_h_rad) * _C
  var2 = Math.sin(_h_rad) * _C
  [_L, var1, var2]
conv['CIELCH']['CIELAB'] = polar_to_scalar
conv['CIELCHuv']['CIELUV'] = polar_to_scalar

# Represents sRGB [0-1] values as [0-225] values. Errors out if value
# out of the range
sRGB_prepare = (tuple) ->
  tuple = (round(n, 3) for n in tuple)
  for ch in tuple
    if ch < 0 or ch > 1
      throw new Error "Trying to represent non-displayable color as hex"
  (Math.round(ch * 255) for ch in tuple)

conv['sRGB']['hex'] = (tuple) ->
  hex = "#"
  tuple = sRGB_prepare tuple
  for ch in tuple
    ch = ch.toString(16)
    ch = "0" + ch if ch.length is 1
    hex += ch
  hex

conv['hex']['sRGB'] = (hex) ->
  if hex.charAt(0) is "#"
    hex = hex.substring 1, 7
  r = hex.substring 0, 2
  g = hex.substring 2, 4
  b = hex.substring 4, 6
  [r, g, b].map (n) ->
    parseInt(n, 16) / 255

converter = (from, to) ->
  # The goal of this function is to find the shortest path
  # between `from` and `to` on this tree:
  #
  #         - CIELAB - CIELCH
  #  CIEXYZ - CIELUV - CIELCHuv
  #         - sRGB - hex
  #         - CIExyY
  #
  # Topologically sorted nodes (child, parent)
  tree = [
    ['CIELCH', 'CIELAB']
    ['CIELCHuv', 'CIELUV']
    ['hex', 'sRGB']
    ['CIExyY', 'CIEXYZ']
    ['CIELAB', 'CIEXYZ']
    ['CIELUV', 'CIEXYZ']
    ['sRGB', 'CIEXYZ']
  ]
  # Recursively generate path. Each recursion makes the tree
  # smaller by elimination a leaf node. This leaf node is either
  # irrelevant to our conversion (trivial case) or it describes
  # an endpoint of our conversion, in which case we add a new 
  # step to the conversion and recurse.
  path = (tree, from, to) ->
    if from is to
      return (t) -> t
    [child, parent] = tree[0]
    # If we start with hex (a leaf node), we know for a fact that 
    # the next node is going to be sRGB (others by analogy)
    if from is child
      # We discovered the first step, now find the rest of the path
      # and return their composition
      p = path(tree.slice(1), parent, to)
      return (t) -> p conv[child][parent] t
    # If we need to end with hex, we know for a fact that the node
    # before it is going to be sRGB (others by analogy)
    if to is child
      # We found the last step, now find the rest of the path and
      # return their composition
      p = path(tree.slice(1), from, parent)
      return (t) -> conv[parent][child] p t
    # The current tree leaf is irrelevant to our path, ignore it and
    # recurse
    p = path tree.slice(1), from, to
    return p
  # Main conversion function
  func = path tree, from, to
  return func

# Make a stylus plugin if stylus exists
try
  stylus = require 'stylus'
  exports = module.exports = ->
    spaces = (space for space of conv when space not in ['sRGB', 'hex'])
    (style) ->
      for space in spaces
        # The code breaks unless you wrap it in ((sp) -> ...)(space)
        # If I spend another minute debugging this problem I will quit
        # programming, grow gills and move to the ocean
        style.define space, ((sp) ->
          (a, b, c) ->
            foo = converter space, 'sRGB'
            [r, g, b] = sRGB_prepare foo [a.val, b.val, c.val]
            new stylus.nodes.RGBA(r, g, b, 1)
        )(space)

# Export to node.js if exports object exists
root = exports ? {}

root.converter = converter

root.make_color = (space1, tuple) ->
  as: (space2) ->
    val = converter(space1, space2)(tuple)
    return val
  is_displayable: ->
    val = converter(space1, 'sRGB')(tuple)
    return within_range(val, [[0, 1], [0, 1], [0, 1]])
  is_visible: ->
    val = converter(space1, 'CIEXYZ')(tuple)
    return within_range(val, [[0, ref_X], [0, ref_Y], [0, ref_Z]])
