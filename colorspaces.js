(function() {
  var clip, conv, dot_product, lab_e, lab_k, root, white_point;
  var __slice = Array.prototype.slice;
  dot_product = function(a, b) {
    var i, ret, _ref;
    ret = 0;
    for (i = 0, _ref = a.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
      ret += a[i] * b[i];
    }
    return ret;
  };
  white_point = [0.95047, 1.00000, 1.08883];
  lab_e = 0.008856;
  lab_k = 903.3;
  clip = function(i) {
    if (i < 0) {
      i = 0;
    }
    if (i > 1) {
      i = 1;
    }
    return i;
  };
  conv = {
    from_CIEXYZ: {
      to_hex: function() {
        var rgb, tuple, _ref, _ref2;
        tuple = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        rgb = (_ref = conv.from_CIEXYZ).to_sRGB.apply(_ref, tuple);
        return (_ref2 = conv.from_sRGB).to_hex.apply(_ref2, rgb);
      },
      to_sRGB: function() {
        var from_linear, m, tuple, _B, _G, _R;
        tuple = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        m = [[3.2406, -1.5372, -0.4986], [-0.9689, 1.8758, 0.0415], [0.0557, -0.2040, 1.0570]];
        from_linear = function(c) {
          var a;
          a = 0.055;
          if (c <= 0.0031308) {
            return 12.92 * c;
          } else {
            return 1.055 * Math.pow(c, 1 / 2.4) - 0.055;
          }
        };
        _R = clip(from_linear(dot_product(m[0], tuple)));
        _G = clip(from_linear(dot_product(m[1], tuple)));
        _B = clip(from_linear(dot_product(m[2], tuple)));
        return [_R, _G, _B];
      },
      to_CIExyY: function(_X, _Y, _Z) {
        var sum;
        sum = _X + _Y + _Z;
        if (sum === 0) {
          return [0, 0, _Y];
        }
        return [_X / sum, _Y / sum, _Y];
      },
      to_CIELAB: function(_X, _Y, _Z) {
        var f, fx, fy, fz, _L, _a, _b;
        f = function(t) {
          if (t > lab_e) {
            return Math.pow(t, 1 / 3);
          } else {
            return 7.787 * t + 16 / 116;
          }
        };
        fx = f(_X / white_point[0]);
        fy = f(_Y / white_point[1]);
        fz = f(_Z / white_point[2]);
        _L = 116 * fy - 16;
        _a = 500 * (fx - fy);
        _b = 200 * (fy - fz);
        return [_L, _a, _b];
      },
      to_CIELCH: function() {
        var lab, tuple, _ref, _ref2;
        tuple = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        lab = (_ref = conv.from_CIEXYZ).to_CIELAB.apply(_ref, tuple);
        return (_ref2 = conv.from_CIELAB).to_CIELCH.apply(_ref2, lab);
      },
      to_CIEXYZ: function() {
        var tuple;
        tuple = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return tuple;
      }
    },
    from_sRGB: {
      to_CIEXYZ: function(_R, _G, _B) {
        var m, rgbl, to_linear, _X, _Y, _Z;
        to_linear = function(c) {
          var a;
          a = 0.055;
          if (c > 0.04045) {
            return Math.pow((c + a) / (1 + a), 2.4);
          } else {
            return c / 12.92;
          }
        };
        m = [[0.4124, 0.3576, 0.1805], [0.2126, 0.7152, 0.0722], [0.0193, 0.1192, 0.9505]];
        rgbl = [to_linear(_R), to_linear(_G), to_linear(_B)];
        _X = dot_product(m[0], rgbl);
        _Y = dot_product(m[1], rgbl);
        _Z = dot_product(m[2], rgbl);
        return [_X, _Y, _Z];
      },
      to_hex: function() {
        var ch, hex, tuple, _i, _len;
        tuple = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        hex = "#";
        for (_i = 0, _len = tuple.length; _i < _len; _i++) {
          ch = tuple[_i];
          ch = Math.round(ch * 255).toString(16);
          if (ch.length === 1) {
            ch = "0" + ch;
          }
          hex += ch;
        }
        return hex;
      }
    },
    from_CIExyY: {
      to_CIEXYZ: function(_x, _y, _Y) {
        var _X, _Z;
        if (_y === 0) {
          return [0, 0, 0];
        }
        _X = _x * _Y / _y;
        _Z = (1 - _x - _y) * _Y / _y;
        return [_X, _Y, _Z];
      }
    },
    from_CIELAB: {
      to_CIEXYZ: function(_L, _a, _b) {
        var f_inv, var_x, var_y, var_z, _X, _Y, _Z;
        var_y = (_L + 16) / 116;
        var_z = var_y - _b / 200;
        var_x = _a / 500 + var_y;
        f_inv = function(t) {
          if (Math.pow(t, 3) > lab_e) {
            return Math.pow(t, 3);
          } else {
            return (116 * t - 16) / lab_k;
          }
        };
        _X = white_point[0] * f_inv(var_x);
        _Y = white_point[1] * f_inv(var_y);
        _Z = white_point[2] * f_inv(var_z);
        return [_X, _Y, _Z];
      },
      to_CIELCH: function(_L, _a, _b) {
        var _C, _h, _h_rad;
        _C = Math.pow(Math.pow(_a, 2) + Math.pow(_b, 2), 1 / 2);
        _h_rad = Math.atan2(_b, _a);
        _h = _h_rad * 360 / 2 / Math.PI;
        if (_h < 0) {
          _h = 360 + _h;
        }
        return [_L, _C, _h];
      }
    },
    from_CIELCH: {
      to_CIELAB: function(_L, _C, _h) {
        var _a, _b, _h_rad;
        _h_rad = _h / 360 * 2 * Math.PI;
        _a = Math.cos(_h_rad) * _C;
        _b = Math.sin(_h_rad) * _C;
        return [_L, _a, _b];
      },
      to_CIEXYZ: function() {
        var lab, tuple, _ref, _ref2;
        tuple = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        lab = (_ref = conv.from_CIELCH).to_CIELAB.apply(_ref, tuple);
        return (_ref2 = conv.from_CIELAB).to_CIEXYZ.apply(_ref2, lab);
      }
    },
    from_hex: {
      to_sRGB: function(hex) {
        var b, g, r;
        if (hex.charAt(0) === "#") {
          hex = hex.substring(1, 7);
        }
        r = hex.substring(0, 2);
        g = hex.substring(2, 4);
        b = hex.substring(4, 6);
        return [r, g, b].map(function(n) {
          return parseInt(n, 16) / 255;
        });
      },
      to_CIEXYZ: function(hex) {
        var rgb, _ref;
        rgb = conv.from_hex.to_sRGB(hex);
        return (_ref = conv.from_sRGB).to_CIEXYZ.apply(_ref, rgb);
      }
    }
  };
  root = typeof exports !== "undefined" && exports !== null ? exports : {};
  root.make_color = function(space, tuple) {
    var color, _ref;
    if (space === 'hex') {
      tuple = [tuple];
    }
    color = (_ref = conv["from_" + space]).to_CIEXYZ.apply(_ref, tuple);
    return {
      as: function(space) {
        var _ref2;
        return (_ref2 = conv.from_CIEXYZ)["to_" + space].apply(_ref2, color);
      }
    };
  };
  if (typeof jQuery !== "undefined" && jQuery !== null) {
    jQuery.colorspaces = root;
  }
}).call(this);
