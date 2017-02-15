colorspaces.min.js: colorspaces.js
	node_modules/.bin/uglifyjs colorspaces.js > colorspaces.min.js

test:
	node tests.js

.PHONY: deploy, test
