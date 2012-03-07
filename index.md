---
layout: default
title: colorspaces.js
---

RGB, the color space we use here on the web is based on display technology, not human color perception. Most meaningful color operations are performed on colors in other color spaces, such as [CIEXYZ][CIEXYZ] or [CIELUV][CIELUV].

## Basic Use

`colorspaces.make_color` takes two arguments: the name of the color space and an array of values representing the color in the color space.

{% highlight javascript %}
var red = $.colorspaces.make_color('sRGB', [1, 0, 0]);
var green = $.colorspaces.make_color('hex', '#00ff00');
var blue = $.colorspaces.make_color('CIEXYZ', [0.1805, 0.0722, 0.9505]);
{% endhighlight %}

The returned object has a method, `as`, that takes the name of a color space as its only argument and returns the coordinates of the color in that color space as an array.

{% highlight javascript %}
> red.as('CIELUV')
[ 53.23288178584245, 175.05303573649485, 37.75050503266512 ]
> blue.as('hex')
'#0000ff'
{% endhighlight %}

These color objects also support two methods, both returning a boolean: `is_displayable` and `is_visible`. The first one determines whether the color is within the sRGB gamut and the second determines whether the color is within the CIE XYZ gamut. Note that both of these methods round the resulting values to three decimal spaces before checking whether they fit into their range; this is a useful policy because of rounding errors.

## Lower Level

If you need to do many color conversions per second, you can optimize by using a low-level function `converter` that takes two color space names as arguments and returns a converter function.

{% highlight javascript %}
> var conv = colorspaces.converter('CIELUV', 'hex')
> conv([53.233, 175.053, 37.75])
'#ff0000'
{% endhighlight %}

## Supported Color Spaces

 * [`sRGB`][sRGB]: Standard RGB, the color space used on the web. All values range between 0 and 1. Be careful, rounding errors can result in values just outside this range.
 * [`CIEXYZ`][CIEXYZ]: One of the first mathematically defined color spaces. Values range between 0 and 0.95047, 1.0 and 1.08883 for X, Y and Z respectively. These three numbers together define the white point, which can be different depending on the chosen illuminant. The commonly used [illuminant D65](http://en.wikipedia.org/wiki/Illuminant_D65) was chosen for this project.
 * `CIExyY`: Normalized version of the above.
 * [`CIELAB`][CIELAB]: A color space made for perceptual uniformity. Recommended for characterization of color surfaces and dyes. L is lightness, spans from 0 to 100.
 * `CIELCH`: A cylindrical representation of CIELAB. L is lightness, C is chroma (think saturation) and H is hue. H spans from 0 to 360.
 * [`CIELUV`][CIELUV]: Another color space made for perceptual uniformity. Recommended for characterization of color displays.
 * `CIELCHuv`: Same as CIELCH, but based on CIELUV.
 * `hex`: A representation of sRGB.

Download the latest `colorspaces.js` file from my [github repo](http://github.com/boronine/colorspaces.js) or install via `npm install colorspaces`.

[CIEXYZ]: http://en.wikipedia.org/wiki/CIE_1931_color_space
[CIELAB]: http://en.wikipedia.org/wiki/Lab_color_space
[sRGB]: http://en.wikipedia.org/wiki/SRGB
[CIELUV]: http://en.wikipedia.org/wiki/CIELUV
