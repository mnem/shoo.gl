module.exports = (grunt) ->
  HTTPD_PORT = 12345;
  APP_SCRIPT_SOURCE = 'source/javascripts'

  grunt.initConfig
    clean:
      build: [ 'build' ]
      testing: [ 'build_test', 'test/headless-tests.js' ]
      clobber: [ 'build', 'build_test', 'test/headless-tests.js', 'bower_components', 'node_modules', '.bundle' ]
    coffee:
      test_subjects:
        options:
          sourceMap: true
          sourceMapDir: 'build_test/'
          join: true
        files:
          "build_test/app_coffeescript_joined.js": "#{APP_SCRIPT_SOURCE}/**/*.coffee"
      test_scripts:
        options:
          join: true
          bare: true
        files:
          "test/headless-tests.js": "test/headless/**/*.coffee"
    shell:
      middleman_deploy:
        command: 'bundle exec middleman deploy'
        options:
          stdout: true
          stderr: true
          failOnError: true
    connect:
      test:
        options:
          port: HTTPD_PORT
    middleman:
      options:
        useBundle: true
      server: {}
      build:
        options:
          command: 'build'
    qunit:
      all: ['test/headless-runner.html']
    coffeelint:
      app: [ "#{APP_SCRIPT_SOURCE}/**/*.coffee" ]
    watch:
      scripts:
        files: "**/*.coffee"
        tasks: ['clear', 'test']

  grunt.loadNpmTasks 'grunt-shell'
  grunt.loadNpmTasks 'grunt-contrib-qunit'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-middleman'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-clear'

  grunt.registerTask 'lint', ['coffeelint']
  grunt.registerTask 'test', ['clean:testing', 'coffee:test_subjects', 'coffee:test_scripts', 'qunit']
  grunt.registerTask 'watch-test', ['watch:scripts']


  grunt.registerTask 'clobber', ['clean:clobber']

  grunt.registerTask 'mm-server', ['middleman:server']
  grunt.registerTask 'mm-build', ['middleman:build']
  grunt.registerTask 'mm-deploy', ['clean:build', 'middleman:build', 'shell:middleman_deploy']
