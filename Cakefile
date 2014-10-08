#
# Build system for urban templates
#

{exec} = require 'child_process'

module = [
 "lib/map.js",
 "lib/county_names.js"
]

bundle_comp = [
  "lib/map.js"
  "lib/counties.geo.js"
  "lib/county_names.js"
]

full = "urban.map"
bundle = "urban.map.bundle"

log = (err, stdout, stderr) ->
  throw err if err
  if stdout or stderr
    console.log stdout + stderr

# Compile all jsfiles into one output file
task 'sbuild', 'Sublime CoffeeBuilder of Urban Module', ->
  # Compile coffee to js
  console.log "Building CoffeScript, compiling to /lib/..."
  exec 'coffee --compile --output lib/ src/', log
  # Smash and minify
  exec "smash #{("./#{m}" for m in module).join(" ")} > ./#{full}.js", log
  exec "smash #{("./#{m}" for m in bundle_comp).join(" ")} > ./#{bundle}.js", log
  for lib in [full, bundle]
    exec "uglifyjs -m -o ./#{lib}.min.js ./#{lib}.js", log

