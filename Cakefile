{exec, spawn} = require 'child_process'

task 'build:js', 'Build JavaScript file and minified version', ->
  exec "coffee --compile colorspaces.coffee && uglifyjs colorspaces.js > colorspaces.min.js"

task 'docker:build', 'Build Docker container for running tasks', ->
  args = ['build', '-t', 'colorspaces-dev-environment', '.']
  console.log 'RUNNING docker ' + args.join(' ') + '\n'
  spawn 'docker', args, {stdio: 'inherit'}

task 'docker:run', 'Run Docker container', ->
  args = [
    'run', '-i', '-t'
    '-v', __dirname + ':/colorspaces'
    'colorspaces-dev-environment'
  ]
  console.log 'RUNNING docker ' + args.join(' ')
  spawn 'docker', args, {stdio: 'inherit'}
