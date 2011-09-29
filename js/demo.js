$(document).ready(function() {
	for (var h = 0; h < 360; h += 30) {
		var square = $('<div class="square">a</div>').appendTo($('#hsl_demo'));
		square.css('background-color', 'hsl(' + h + ', 80%, 50%)');
	}
	for (var h = 0; h < 360; h += 30) {
		var square = $('<div class="square">a</div>').appendTo($('#lch_demo'));
		var color = $.colorspaces.make_color('CIELCH', [65, 100, h]);
		square.css('background-color', color.as('hex'));
	}
});
