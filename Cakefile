{exec, spawn} = require 'child_process'

task 'build:js', 'Build JavaScript file and minified version', ->
  exec "coffee --compile colorspaces.coffee && uglifyjs colorspaces.js > colorspaces.min.js"
