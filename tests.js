var assert = require('assert');
var colorspaces = require('./colorspaces.js');

var colors = {
  indigo: {
    'hex': '#4b0082',
    'sRGB': [0.29412, 0.00000, 0.50980],
    'CIEXYZ': [0.06931, 0.03108, 0.21354],
    'CIExyY': [0.22079, 0.09899, 0.03108],
    'CIELAB': [20.470, 51.695, -53.320],
    'CIELCH': [20.470, 74.265, 314.113],
    'CIELUV': [20.470, 10.084, -61.343]
  },
  crimson: {
    'hex': '#dc143c',
    'sRGB': [0.86275, 0.07843, 0.23529],
    'CIEXYZ': [0.30581, 0.16042, 0.05760],
    'CIExyY': [0.58380, 0.30625, 0.16042],
    'CIELAB': [47.030, 70.936, 33.595],
    'CIELCH': [47.030, 78.489, 25.342],
    'CIELUV': [47.030, 138.278, 19.641]
  },
  white: {
    'hex': '#ffffff',
    'sRGB': [1, 1, 1],
    'CIEXYZ': [0.95050, 1.00000, 1.08900],
    'CIExyY': [0.31272, 0.32900, 1],
    'CIELAB': [100, 0.005, -0.010],
    'CIELUV': [100, 0.001, -0.017]
  },
  // CIELCH omitted because Hue is almost completely
  // irrelevant for white and its big rounding error
  // is acceptable here. Hue is better tested with 
  // more saturated colors, like the two above
  black: {
    'hex': '#000000',
    'sRGB': [0, 0, 0],
    'CIEXYZ': [0, 0, 0],
    'CIExyY': [0, 0, 0],
    'CIELAB': [0, 0, 0],
    'CIELUV': [0, 0, 0]
  }
};
// CIELCH omitted

var permissible_error = {
  'CIELAB': 0.01,
  'CIEXYZ': 0.001,
  'CIExyY': 0.001,
  'CIELCH': 0.01,
  'CIELUV': 0.01,
  'sRGB': 0.001
};

// Returns the biggest difference factor between two corresponding
// elements in two tuples
var big_dif = function big_dif(tuple1, tuple2) {
  var ret = 0;
  var iterable = __range__(0, tuple1.length - 1, true);
  for (var j = 0; j < iterable.length; j++) {
    var i = iterable[j];
    var dif = Math.abs(tuple1[i] - tuple2[i]);
    if (dif > ret) {
      ret = dif;
    }
  }
  return ret;
};

// For every test color
for (var name in colors) {
  // Make a color object for every definition of the test color
  var definitions = colors[name];
  for (var space1 in definitions) {
    // Convert each of those to every color space and compare
    var tuple1 = definitions[space1];
    for (var space2 in definitions) {
      var tuple2 = definitions[space2];
      var output = colorspaces.converter(space1, space2)(tuple1);
      // If the target space is hex, simply compare the two for equality
      if (space2 === 'hex') {
        assert.ok(output === tuple2, '\n\n          Error when converting ' + space1 + ' to hex\n');
        continue;
      }
      // Otherwise first make sure there are no NaNs
      for (var i = 0; i < output.length; i++) {
        var val = output[i];
        assert.ok(!isNaN(val), '\n\n          NaN returned when converting from ' + space1 + ' to ' + space2 + '\n\n          ' + output + '\n');
      }
      // Then calculate the biggest difference
      var dif = big_dif(tuple2, output);
      // ... and see if it's too big
      assert.ok(dif <= permissible_error[space2], '\n\n        Big error when converting from ' + space1 + ' to ' + space2 + '\n\n        Input: ' + tuple1 + '\n\n        Output: ' + output + '\n\n        Should be: ' + tuple2 + '\n');
    }
  }
  console.log(name + " ok");
}

var styl = ".someclass\n color CIEXYZ(0.30581, 0.16042, 0.0576)\n color CIExyY(0.58380, 0.30625, 0.16042)\n color CIELAB(47.030, 70.936, 33.595)\n color CIELCH(47.030, 78.489, 25.342)\n color CIELUV(47.030, 138.278, 19.641)\n";

var css = ".someclass { color: #dc143c; color: #dc143c; color: #dc143c; color: #dc143c; color: #dc143c; }";

// Whitespace doesn't matter
var nows = function nows(text) {
  return text.replace(/\s+/g, '');
};

try {
  var stylus = require('stylus');
} catch (error) {}
if (stylus != null) {
  stylus(styl).use(colorspaces()).render(function (err, test_css) {
    if (err) {
      throw err;
    }
    if (nows(test_css) === nows(css)) {
      return console.log('Stylus works');
    } else {
      return console.log('STYLUS ERROR' + test_css);
    }
  });
}

function __range__(left, right, inclusive) {
  var range = [];
  var ascending = left < right;
  var end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (var _i = left; ascending ? _i < end : _i > end; ascending ? _i++ : _i--) {
    range.push(_i);
  }
  return range;
}

