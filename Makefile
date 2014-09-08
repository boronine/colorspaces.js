colorspaces.js: colorspaces.coffee
	coffee --compile colorspaces.coffee

colorspaces.min.js: colorspaces.js
	uglifyjs colorspaces.js > colorspaces.min.js
