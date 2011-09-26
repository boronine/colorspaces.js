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

_sRGB_to_CIEXYZ = (_R, _G, _B) ->
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
  x: res[0][0]
  y: res[1][0]
  z: res[2][0]

_CIEXYZ_to_sRGB = (_X, _Y, _Z) ->
  from_linear = (c) ->
    a = 0.055
    if c <= 0.0031308
      return 12.92 * c
    else
      return (1 + a) * Math.pow(c, 1 / 2.4) - a
  m = [
    [3.2406, -1.5372, -0.4986]
    [-0.9689, 1.8758, 0.0415]
    [0.0557, -0.2040, 1.0570]
  ]
  res = matrix_mult m, [[_X], [_Y], [_Z]]
  x: from_linear res[0][0]
  y: from_linear res[1][0]
  z: from_linear res[2][0]

# _CIEXYZ_to_CIELAB = (_X, _Y, _Z) ->
#   f = (t) ->
#     if t > Math.pow(6 / 29, 3)
#       Math.pow(t, 1 / 3)
#     else
#       (1 / 3) * Math.pow(29 / 6, 2) * t + 4 / 29

