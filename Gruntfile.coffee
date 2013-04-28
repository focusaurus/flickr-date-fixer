setupGrunt = (grunt) ->
  grunt.initConfig
    requirejs:
      build:
        options:
          mainConfigFile: "generated/js/build.js"
          baseUrl: "generated/js"
          name: "main"
          include: ["build"]
          out: "generated/rjs/js/main.js"
    coffee:
      compile:
        expand: true
        cwd: "app/browser"
        src: "**/*.coffee"
        dest: "generated/js"
        ext: ".js"
    copy:
      main:
        cwd: 'static'
        src: '**/*.js'
        dest: 'generated'
        expand: true
    clean:
      generated: "generated"
      buildjs: "generated/js/build.js"
    stylus:
      compile:
        files:
          "generated/application.css": "app/browser/application.styl"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-requirejs"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.registerTask "prepublish", ["clean:generated", "copy", "coffee", "requirejs", "clean:buildjs", "stylus"]
  grunt.registerTask "default", "prepublish"

module.exports = setupGrunt
