# All Math on this page comes from http://www.easyrgb.com
# 
dot_product = (a, b) ->
  ret = 0
  for i in [0..a.length-1]
    ret += a[i] * b[i]
  return ret

# The D65 standard illuminant
ref_X = 0.95047
ref_Y = 1.00000
ref_Z = 1.08883
ref_U = (4 * ref_X) / (ref_X + (15 * ref_Y) + (3 * ref_Z))
ref_V = (9 * ref_Y) / (ref_X + (15 * ref_Y) + (3 * ref_Z))

# CIE L*a*b* constants
lab_e = 0.008856
lab_k = 903.3

# Used for Lab and LUV conversions
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

# Functions for converting between CIE XYZ and other color spaces
# Most of these taken directly from Wikipedia
conv =
  from_CIEXYZ:
    to_hex: (tuple...) ->
      rgb = conv.from_CIEXYZ.to_sRGB tuple...
      conv.from_sRGB.to_hex rgb...
    to_sRGB: (tuple...) ->
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
    to_CIExyY: (_X, _Y, _Z) ->
      sum = _X + _Y + _Z
      if sum is 0
        return [0, 0, _Y]
      [_X / sum, _Y / sum, _Y]
    to_CIELAB: (_X, _Y, _Z) ->
      fx = f _X / ref_X
      fy = f _Y / ref_Y
      fz = f _Z / ref_Z
      _L = 116 * fy - 16
      _a = 500 * (fx - fy)
      _b = 200 * (fy - fz)
      [_L, _a, _b]
    to_CIELUV: (_X, _Y, _Z) ->
      var_U = (4 * _X) / (_X + (15 * _Y) + (3 * _Z))
      var_V = (9 * _Y) / (_X + (15 * _Y) + (3 * _Z))
      _L = 116 * f(_Y / ref_Y) - 16
      # Black will create a divide-by-zero error
      if _L is 0
        return [0, 0, 0]
      _U = 13 * _L * (var_U - ref_U)
      _V = 13 * _L * (var_V - ref_V)
      [_L, _U, _V]
    to_CIELCH: (tuple...) ->
      lab = conv.from_CIEXYZ.to_CIELAB tuple...
      conv.from_CIELAB.to_CIELCH lab...
    to_CIEXYZ: (tuple...) -> tuple
  from_sRGB:
    to_CIEXYZ: (_R, _G, _B) ->
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
    to_hex: (tuple...) ->
      hex = "#"
      for ch in tuple
        ch = Math.round(ch * 255).toString(16)
        ch = "0" + ch if ch.length is 1
        hex += ch
      hex
  from_CIExyY:
    to_CIEXYZ: (_x, _y, _Y) ->
      if _y is 0
        return [0, 0, 0]
      _X = _x * _Y / _y
      _Z = (1 - _x - _y) * _Y / _y
      [_X, _Y, _Z]
  from_CIELUV:
    to_CIEXYZ: (_L, _U, _V) ->
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
  from_CIELAB:
    to_CIEXYZ: (_L, _a, _b) ->
      var_y = (_L + 16) / 116
      var_z = var_y - _b / 200
      var_x = _a / 500 + var_y
      _X = ref_X * f_inv(var_x)
      _Y = ref_Y * f_inv(var_y)
      _Z = ref_Z * f_inv(var_z)
      [_X, _Y, _Z]
    to_CIELCH: (_L, _a, _b) ->
      _C = Math.pow Math.pow(_a, 2) + Math.pow(_b, 2), 1 / 2
      _h_rad = Math.atan2 _b, _a
      _h = _h_rad * 360 / 2 / Math.PI
      _h = 360 + _h if _h < 0
      [_L, _C, _h]
  from_CIELCH:
    to_CIELAB: (_L, _C, _h) ->
      _h_rad = _h / 360 * 2 * Math.PI
      _a = Math.cos(_h_rad) * _C
      _b = Math.sin(_h_rad) * _C
      [_L, _a, _b]
    to_CIEXYZ: (tuple...) ->
      lab = conv.from_CIELCH.to_CIELAB tuple...
      conv.from_CIELAB.to_CIEXYZ lab...
  from_hex:
    to_sRGB: (hex) ->
      if hex.charAt(0) is "#"
        hex = hex.substring 1, 7
      r = hex.substring 0, 2
      g = hex.substring 2, 4
      b = hex.substring 4, 6
      [r, g, b].map (n) ->
        parseInt(n, 16) / 255
    to_CIEXYZ: (hex) ->
      rgb = conv.from_hex.to_sRGB hex
      conv.from_sRGB.to_CIEXYZ rgb...

# Rounds number to a given number of decimal spaces
round = (num, spaces) ->
  m = Math.pow 10, spaces
  return Math.round(num * m) / m

# Returns whether given color coordinates fit within their valid range
validate = (space, tuple) ->
  if space is 'sRGB'
    req = [[0, 1], [0, 1], [0, 1]]
    tuple = (round(n, 4) for n in tuple)
  else if space is 'CIEXYZ'
    req = [[0, 0.95050], [0, 1.00000], [0, 1.08900]]
    tuple = (round(n, 4) for n in tuple)
  else
    return true
  if tuple.length isnt req.length
    return false
  for i in [0..tuple.length - 1]
    if tuple[i] < req[i][0] or tuple[i] > req[i][1]
      return false
  return true

# Export to node.js if exports object exists
root = exports ? {}

root.make_color = (space, tuple) ->
  if space is 'hex'
    tuple = [tuple]
  if not validate(space, tuple)
    throw new Error "Color is out of the gamut of the given color space"
  color = conv["from_" + space].to_CIEXYZ(tuple...)
  if not validate('CIEXYZ', color)
    throw new Error "Invalid color"
  as: (space) ->
    val = conv.from_CIEXYZ["to_" + space](color...)
    if not validate(space, val)
      throw new Error "Color is out of the gamut of the requested color space"
    return val

# Export to jQuery if jQuery object exists
if jQuery?
  jQuery.colorspaces = root

