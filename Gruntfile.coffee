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
        src: ["**/*.coffee"]
        dest: "generated/js"
        ext: ".js"
    clean: ["generated"]
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-requirejs"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.registerTask "default", ["requirejs"]

module.exports = setupGrunt
