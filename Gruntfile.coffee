module.exports = (grunt) ->
  HTTPD_PORT = 12345;

  grunt.initConfig
    # shell:
    #   test:
    #     command: "slimerjs runner.js http://localhost:#{HTTPD_PORT}/test/all.html"
    #     options:
    #       stdout: true
    #       stderr: true
    #       failOnError: true
    clean:
      build: [ 'build' ]
      clobber: [ 'build', 'bower_components', 'node_modules', '.bundle' ]
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

  grunt.loadNpmTasks 'grunt-shell'
  grunt.loadNpmTasks 'grunt-contrib-qunit'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-middleman'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  grunt.registerTask 'test', ['qunit']

  grunt.registerTask 'clobber', ['clean:clobber']

  grunt.registerTask 'mm-server', ['middleman:server']
  grunt.registerTask 'mm-build', ['middleman:build']
  grunt.registerTask 'mm-deploy', ['clean', 'middleman:build', 'shell:middleman_deploy']
