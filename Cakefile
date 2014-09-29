{exec} = require 'child_process'

module = [
 "lib/map.js", "lib/counties.geo.js"
]

full = "urban.map"

log = (err, stdout, stderr) ->
  throw err if err
  if stdout or stderr
    console.log stdout + stderr

# Compile all jsfiles into one output file
task 'sbuild', 'Sublime CoffeeBuilder of UrbanMap', ->
  # Compile coffee to js
  console.log "Building CoffeScript, compiling to /lib/..."
  exec 'coffee --compile --output lib/ src/', log
  # Smash and minify
  exec "smash #{("./#{m}" for m in module).join(" ")} > ./lib/#{full}.js", log
  exec "uglifyjs -m -o ./lib/#{full}.min.js ./lib/#{full}.js", log

