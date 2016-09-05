(function () {

  // All Math on this page comes from http://www.easyrgb.com
  var dot_product = function dot_product(a, b) {
    var ret = 0;
    var iterable = __range__(0, a.length - 1, true);
    for (var j = 0; j < iterable.length; j++) {
      var i = iterable[j];
      ret += a[i] * b[i];
    }
    return ret;
  };

  // Rounds number to a given number of decimal places
  var round = function round(num, places) {
    var m = Math.pow(10, places);
    return Math.round(num * m) / m;
  };

  // Returns whether given color coordinates fit within their valid range
  var within_range = function within_range(vector, ranges) {
    // Round to three decimal places to avoid rounding errors
    // e.g. R_rgb = -0.0000000001
    vector = vector.map(function (n) {
      return round(n, 3);
    });
    var iterable = __range__(0, vector.length - 1, true);
    for (var j = 0; j < iterable.length; j++) {
      var i = iterable[j];
      if (vector[i] < ranges[i][0] || vector[i] > ranges[i][1]) {
        return false;
      }
    }
    return true;
  };

  // The D65 standard illuminant
  var ref_X = 0.95047;
  var ref_Y = 1.00000;
  var ref_Z = 1.08883;
  var ref_U = 4 * ref_X / (ref_X + 15 * ref_Y + 3 * ref_Z);
  var ref_V = 9 * ref_Y / (ref_X + 15 * ref_Y + 3 * ref_Z);

  // CIE L*a*b* constants
  var lab_e = 0.008856;
  var lab_k = 903.3;

  // Used for Lab and Luv conversions
  var f = function f(t) {
    if (t > lab_e) {
      return Math.pow(t, 1 / 3);
    } else {
      return 7.787 * t + 16 / 116;
    }
  };
  var f_inv = function f_inv(t) {
    if (Math.pow(t, 3) > lab_e) {
      return Math.pow(t, 3);
    } else {
      return (116 * t - 16) / lab_k;
    }
  };

  // This map will contain our conversion functions
  // conv[from][to] = (tuple) -> ...
  var conv = {
    'CIEXYZ': {},
    'CIExyY': {},
    'CIELAB': {},
    'CIELCH': {},
    'CIELUV': {},
    'CIELCHuv': {},
    'sRGB': {},
    'hex': {}
  };

  conv['CIEXYZ']['sRGB'] = function (tuple) {
    var m = [[3.2406, -1.5372, -0.4986], [-0.9689, 1.8758, 0.0415], [0.0557, -0.2040, 1.0570]];
    var from_linear = function from_linear(c) {
      var a = 0.055;
      if (c <= 0.0031308) {
        return 12.92 * c;
      } else {
        return 1.055 * Math.pow(c, 1 / 2.4) - 0.055;
      }
    };
    var _R = from_linear(dot_product(m[0], tuple));
    var _G = from_linear(dot_product(m[1], tuple));
    var _B = from_linear(dot_product(m[2], tuple));
    return [_R, _G, _B];
  };

  conv['sRGB']['CIEXYZ'] = function (tuple) {
    var _R = tuple[0];
    var _G = tuple[1];
    var _B = tuple[2];
    var to_linear = function to_linear(c) {
      var a = 0.055;
      if (c > 0.04045) {
        return Math.pow((c + a) / (1 + a), 2.4);
      } else {
        return c / 12.92;
      }
    };
    var m = [[0.4124, 0.3576, 0.1805], [0.2126, 0.7152, 0.0722], [0.0193, 0.1192, 0.9505]];
    var rgbl = [to_linear(_R), to_linear(_G), to_linear(_B)];
    var _X = dot_product(m[0], rgbl);
    var _Y = dot_product(m[1], rgbl);
    var _Z = dot_product(m[2], rgbl);
    return [_X, _Y, _Z];
  };

  conv['CIEXYZ']['CIExyY'] = function (tuple) {
    var _X = tuple[0];
    var _Y = tuple[1];
    var _Z = tuple[2];
    var sum = _X + _Y + _Z;
    if (sum === 0) {
      return [0, 0, _Y];
    }
    return [_X / sum, _Y / sum, _Y];
  };

  conv['CIExyY']['CIEXYZ'] = function (tuple) {
    var _x = tuple[0];
    var _y = tuple[1];
    var _Y = tuple[2];
    if (_y === 0) {
      return [0, 0, 0];
    }
    var _X = _x * _Y / _y;
    var _Z = (1 - _x - _y) * _Y / _y;
    return [_X, _Y, _Z];
  };

  conv['CIEXYZ']['CIELAB'] = function (tuple) {
    var _X = tuple[0];
    var _Y = tuple[1];
    var _Z = tuple[2];
    var fx = f(_X / ref_X);
    var fy = f(_Y / ref_Y);
    var fz = f(_Z / ref_Z);
    var _L = 116 * fy - 16;
    var _a = 500 * (fx - fy);
    var _b = 200 * (fy - fz);
    return [_L, _a, _b];
  };

  conv['CIELAB']['CIEXYZ'] = function (tuple) {
    var _L = tuple[0];
    var _a = tuple[1];
    var _b = tuple[2];
    var var_y = (_L + 16) / 116;
    var var_z = var_y - _b / 200;
    var var_x = _a / 500 + var_y;
    var _X = ref_X * f_inv(var_x);
    var _Y = ref_Y * f_inv(var_y);
    var _Z = ref_Z * f_inv(var_z);
    return [_X, _Y, _Z];
  };

  conv['CIEXYZ']['CIELUV'] = function (tuple) {
    var _X = tuple[0];
    var _Y = tuple[1];
    var _Z = tuple[2];
    var var_U = 4 * _X / (_X + 15 * _Y + 3 * _Z);
    var var_V = 9 * _Y / (_X + 15 * _Y + 3 * _Z);
    var _L = 116 * f(_Y / ref_Y) - 16;
    // Black will create a divide-by-zero error
    if (_L === 0) {
      return [0, 0, 0];
    }
    var _U = 13 * _L * (var_U - ref_U);
    var _V = 13 * _L * (var_V - ref_V);
    return [_L, _U, _V];
  };

  conv['CIELUV']['CIEXYZ'] = function (tuple) {
    var _L = tuple[0];
    var _U = tuple[1];
    var _V = tuple[2];
    // Black will create a divide-by-zero error
    if (_L === 0) {
      return [0, 0, 0];
    }
    var var_Y = f_inv((_L + 16) / 116);
    var var_U = _U / (13 * _L) + ref_U;
    var var_V = _V / (13 * _L) + ref_V;
    var _Y = var_Y * ref_Y;
    var _X = 0 - 9 * _Y * var_U / ((var_U - 4) * var_V - var_U * var_V);
    var _Z = (9 * _Y - 15 * var_V * _Y - var_V * _X) / (3 * var_V);
    return [_X, _Y, _Z];
  };

  var scalar_to_polar = function scalar_to_polar(tuple) {
    var _L = tuple[0];
    var var1 = tuple[1];
    var var2 = tuple[2];
    var _C = Math.pow(Math.pow(var1, 2) + Math.pow(var2, 2), 1 / 2);
    var _h_rad = Math.atan2(var2, var1);
    var _h = _h_rad * 360 / 2 / Math.PI;
    if (_h < 0) {
      _h = 360 + _h;
    }
    return [_L, _C, _h];
  };
  conv['CIELAB']['CIELCH'] = scalar_to_polar;
  conv['CIELUV']['CIELCHuv'] = scalar_to_polar;

  var polar_to_scalar = function polar_to_scalar(tuple) {
    var _L = tuple[0];
    var _C = tuple[1];
    var _h = tuple[2];
    var _h_rad = _h / 360 * 2 * Math.PI;
    var var1 = Math.cos(_h_rad) * _C;
    var var2 = Math.sin(_h_rad) * _C;
    return [_L, var1, var2];
  };
  conv['CIELCH']['CIELAB'] = polar_to_scalar;
  conv['CIELCHuv']['CIELUV'] = polar_to_scalar;

  // Represents sRGB [0-1] values as [0-225] values. Errors out if value
  // out of the range
  var sRGB_prepare = function sRGB_prepare(tuple) {
    tuple = tuple.map(function (n) {
      return round(n, 3);
    });
    for (var i = 0; i < tuple.length; i++) {
      var ch = tuple[i];
      if (ch < 0 || ch > 1) {
        throw new Error("Illegal sRGB value");
      }
    }
    return tuple.map(function (ch) {
      return Math.round(ch * 255);
    });
  };

  conv['sRGB']['hex'] = function (tuple) {
    var hex = "#";
    tuple = sRGB_prepare(tuple);
    for (var i = 0; i < tuple.length; i++) {
      var ch = tuple[i];
      ch = ch.toString(16);
      if (ch.length === 1) {
        ch = '0' + ch;
      }
      hex += ch;
    }
    return hex;
  };

  conv['hex']['sRGB'] = function (hex) {
    if (hex.charAt(0) === "#") {
      hex = hex.substring(1, 7);
    }
    var r = hex.substring(0, 2);
    var g = hex.substring(2, 4);
    var b = hex.substring(4, 6);
    return [r, g, b].map(function (n) {
      return parseInt(n, 16) / 255;
    });
  };

  var converter = function converter(from, to) {
    // The goal of this function is to find the shortest path
    // between `from` and `to` on this tree:
    //
    //         - CIELAB - CIELCH
    //  CIEXYZ - CIELUV - CIELCHuv
    //         - sRGB - hex
    //         - CIExyY
    //
    // Topologically sorted nodes (child, parent)
    var tree = [['CIELCH', 'CIELAB'], ['CIELCHuv', 'CIELUV'], ['hex', 'sRGB'], ['CIExyY', 'CIEXYZ'], ['CIELAB', 'CIEXYZ'], ['CIELUV', 'CIEXYZ'], ['sRGB', 'CIEXYZ']];
    // Recursively generate path. Each recursion makes the tree
    // smaller by elimination a leaf node. This leaf node is either
    // irrelevant to our conversion (trivial case) or it describes
    // an endpoint of our conversion, in which case we add a new 
    // step to the conversion and recurse.
    var path = function path(tree, from, to) {
      if (from === to) {
        return function (t) {
          return t;
        };
      }
      var child = tree[0][0];
      var parent = tree[0][1];
      // If we start with hex (a leaf node), we know for a fact that 
      // the next node is going to be sRGB (others by analogy)
      if (from === child) {
        // We discovered the first step, now find the rest of the path
        // and return their composition
        var p = path(tree.slice(1), parent, to);
        return function (t) {
          return p(conv[child][parent](t));
        };
      }
      // If we need to end with hex, we know for a fact that the node
      // before it is going to be sRGB (others by analogy)
      if (to === child) {
        // We found the last step, now find the rest of the path and
        // return their composition
        var p = path(tree.slice(1), from, parent);
        return function (t) {
          return conv[parent][child](p(t));
        };
      }
      // The current tree leaf is irrelevant to our path, ignore it and
      // recurse
      var p = path(tree.slice(1), from, to);
      return p;
    };
    // Main conversion function
    var func = path(tree, from, to);
    return func;
  };

  var root = {};

  // If Stylus is installed, make module.exports work as a plugin
  try {
    (function () {
      var stylus = require('stylus');
      root = function root() {
        var spaces = Object.keys(conv).filter(function (space) {
          return space !== 'sRGB' && space !== 'hex';
        }).map(function (space) {
          return space;
        });
        return function (style) {
          return spaces.map(function (space) {
            return style.define(space, function (space) {
              return function (a, b, c) {
                var g = void 0,
                    r = void 0;
                var foo = converter(space, 'sRGB');
                var rgb = sRGB_prepare(foo([a.val, b.val, c.val]));
                return new stylus.nodes.RGBA(rgb[0], rgb[1], rgb[2], 1);
              };
            }(space));
          });
        };
      };
    })();
  } catch (error) {}

  root.converter = converter;
  root.make_color = function (space1, tuple) {
    return {
      as: function as(space2) {
        var val = converter(space1, space2)(tuple);
        return val;
      },
      is_displayable: function is_displayable() {
        var val = converter(space1, 'sRGB')(tuple);
        return within_range(val, [[0, 1], [0, 1], [0, 1]]);
      },
      is_visible: function is_visible() {
        var val = converter(space1, 'CIEXYZ')(tuple);
        return within_range(val, [[0, ref_X], [0, ref_Y], [0, ref_Z]]);
      }
    };
  };

  // Export to Node.js
  if (typeof module !== 'undefined' && module !== null) {
    module.exports = root;
  }
  // Export to jQuery
  if (typeof jQuery !== 'undefined' && jQuery !== null) {
    jQuery.colorspaces = root;
  }
  // Make a stylus plugin if stylus exists

  function __range__(left, right, inclusive) {
    var range = [];
    var ascending = left < right;
    var end = !inclusive ? right : ascending ? right + 1 : right - 1;
    for (var i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
      range.push(i);
    }
    return range;
  }
  
})();

