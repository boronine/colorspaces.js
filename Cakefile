{exec} = require 'child_process'
task 'build', 'Build project', ->
  exec 'coffee --compile colorspaces.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
    exec 'uglifyjs colorspaces.js > colorspaces.min.js', (err, stdout, stderr) ->
      throw err if err
      console.log stderr

