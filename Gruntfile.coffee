#
# Build System for Modeler Project
# Ben Southgate
# 10/07/14
#


module.exports = (grunt) ->
  # Register configuration
  grunt.initConfig
    uglify:
      options:
        mangle: true
      js:
        files:
          './urban.map.min.js' : ['./urban.map.js']
    coffee:
      compile:
        options :
          join : true
        files:
          # Concatenate all components and compile
          './lib/map.js': [
            #
            # map Coffeescript file
            #
            './src/map.coffee'
          ]
    watch:
      coffee :
        files: [
          './src/*.coffee'
        ],
        tasks: ['coffee', 'concat', 'uglify:js']
      html :
        files : ['./examples/example.html']
      options :
        livereload : true
    concat :
      options :
        separator : ';'
      dist :
        src : [
          "lib/map.js",
          "lib/counties.geo.js",
          "lib/county_names.js"
        ]
        dest : './urban.map.js'
    browserSync:
      bsFiles:
        src : [
          './urban.map.js',
          './examples/index.html'
        ]
      options:
        watchTask: true
        server:
            baseDir: "./"

  libs = [
   'grunt-contrib-uglify'
   'grunt-contrib-watch'
   'grunt-browser-sync'
   'grunt-contrib-concat'
   'grunt-contrib-coffee'
  ]

  grunt.loadNpmTasks(pkg) for pkg in libs

  # Coffee compiling, uglifying and watching in order
  grunt.registerTask 'default', [
    'coffee',
    'concat',
    'uglify:js',
    'browserSync',
    'watch'
  ]