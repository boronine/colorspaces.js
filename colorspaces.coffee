# Some basic Linear Algebra to be used for color conversions
# Here the matrix
#
#  | a, b |
#  | c, d |
#
#  is represented by [[a, b], [c, d]]
dot_product = (a, b) ->
  ret = 0
  for i in [0..a.length-1]
    do (i) ->
      ret += a[i] * b[i]
  return ret
num_rows = (a) -> a.length
get_row = (a, i) -> a[i]
num_cols = (a) -> a[0].length
get_col = (a, i) -> (row[i] for row in a)
matrix_mult = (a, b) ->
  m = num_rows(a)
  p = num_rows(b) # equvalently cols(a)
  n = num_cols(b)
  ab = []
  for i in [0..m-1]
    do (i) ->
      ab.push []
      for j in [0..n-1]
        do (j) ->
          ab[i].push dot_product get_row(a, i), get_col(b, j)
  return ab

# The D65 standard illuminant
white_point = [95.047, 100.000, 108.883]

# Functions for converting between CIE XYZ and other color spaces
# Most of these taken directly from Wikipedia
conv = 
  _CIEXYZ:
    to: (tuple) -> tuple
    from: (tuple) -> tuple
  _sRGB:
    to: (_X, _Y, _Z) ->
      from_linear = (c) ->
        a = 0.055
        if c <= 0.0031308
          12.92 * c
        else
          (1 + a) * Math.pow(c, 1 / 2.4) - a
      m = [
        [3.2406, -1.5372, -0.4986]
        [-0.9689, 1.8758, 0.0415]
        [0.0557, -0.2040, 1.0570]
      ]
      res = matrix_mult m, [[_X], [_Y], [_Z]]
      _R = from_linear res[0][0]
      _G = from_linear res[1][0]
      _B = from_linear res[2][0]
      [_R, _G, _B]
    from: (_R, _G, _B) ->
      to_linear = (c) ->
        a = 0.055
        if c <= 0.04045
          return c / 12.92
        else
          return Math.pow (c + a) / (1 + a), 2.4
      m = [
        [0.4124, 0.3576, 0.1805]
        [0.2126, 0.7152, 0.0722]
        [0.0193, 0.1192, 0.9505]
      ]
      rl = to_linear _R
      gl = to_linear _G
      bl = to_linear _B
      res = matrix_mult m, [[rl], [gl], [bl]]
      [res[0][0], res[1][0], res[2][0]]
  _CIExyY:
    to: (_X, _Y, _Z) ->
      sum = _X + _Y + _Z
      [_X / sum, _Y / sum, _Y]
    from: (_x, _y, _Y) ->
      _X = _Y / _y * _x
      _Z = _Y / _y * (1 - _x - _y)
      [_X, _Y, _X]
  _CIELAB:
    to: (_X, _Y, _Z) ->
      _X = _X / white_point[0]
      _Y = _Y / white_point[1]
      _Z = _Z / white_point[2]
      f = (t) ->
        if t > Math.pow(6 / 29, 3)
          Math.pow(t, 1 / 3)
        else
          (1 / 3) * Math.pow(29 / 6, 2) * t + 4 / 29
      _L = 116 * f(_Y) - 16
      _a = 500 * (f(_X) - f(_Y))
      _b = 200 * (f(_Y) - f(_Z))
      [_L, _a, _b]
    from: (_L, _a, _b) ->
      f_inv = (t) ->
        if t > 6 / 29
          Math.pow(t, 3)
        else
          3 * Math.pow(6 / 29, 2) * (t - 4 / 29)
      _Y = white_point[1] * f_inv 1 / 116 * (_L + 16)
      _X = white_point[0] * f_inv 1 / 116 * (_L + 16) + 1 / 500 * _a
      _Z = white_point[2] * f_inv 1 / 116 * (_L + 16) - 1 / 200 * _b
      [_X, _Y, _Z]
  _CIELCH:
    to: (_X, _Y, _Z) ->
      [_L, _a, _b] = conv._CIELAB.to([_X, _Y, _Z])
      _C = Math.pow Math.pow(_a, 2) + Math.pow(_b, 2), 1 / 2
      _h = Math.atan2 _b, _a
      [_L, _C, _h]
    from: (_L, _C, _h) ->
      _h_rad = _h / 360 * 2 * Math.PI
      _a = Math.cos(_h_rad) * _C
      _b = Math.sin(_h_rad) * _C
      conv._CIELAB.from([_L, _a, _b])

get_color = (space, tuple) ->
  color = conv["_" + space].from(tuple...)
  as: (space) ->
    conv["_" + space].to(color...)

if jQuery?
  exports =
    get_color: get_color
  jQuery.colorspaces = exports

