docs/index.html: src/build.js
	node src/build.js > docs/index.html

colorspaces.js: src/colorspaces.js
	node_modules/.bin/babel --presets es2015 src/colorspaces.js > colorspaces.js

colorspaces.min.js: colorspaces.js
	node_modules/.bin/uglifyjs colorspaces.js > colorspaces.min.js

deploy:
	aws s3 sync docs s3://colorspaces.boronine.com

.PHONY: deploy
