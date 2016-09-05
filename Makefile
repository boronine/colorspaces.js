docs/index.html: homepage.js
	node homepage.js > docs/index.html

colorspaces.min.js: colorspaces.js
	node_modules/.bin/uglifyjs colorspaces.js > colorspaces.min.js

deploy:
	aws s3 sync docs s3://colorspaces.boronine.com

test:
	node tests.js

.PHONY: deploy, test
