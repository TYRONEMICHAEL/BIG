### Export our grunt module ###
module.exports = (grunt) ->
	### Utility function to mount a folder to be served statically ###
	mountFolder = (connect, dir) -> connect.static require('path').resolve(dir)

	### Configurable options ###
	options = 
		CONNECT_PORT: 8000
		HOSTNAME: 'localhost'
		LIVERELOAD_PORT: 35729

	### Livereload snippet that will be injected into our page ###
	lrSnippet = require('connect-livereload') port: options.LIVERELOAD_PORT
	
	### Load all grunt tasks ###
	require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

	grunt.initConfig
		config: options
		pkg: grunt.file.readJSON 'package.json'
		
		### Watches files then call the appropriate tasks ###
		watch:
			coffee:
				files: ['app/**/*.coffee']
				tasks: ['coffee']

			compass:
				files: ['app/**/*.scss']
				tasks: ['compass']

			livereload:
				options: 
					livereload: true
				files: [
					'app/*.html'
                    '{.tmp,app}/css/{,*/}*.css'
                    '{.tmp,app}/scripts/{,*/}*.js'
                    'app/images/{,*/}*.{png,jpg,jpeg,gif,webp}'
				]

		### Compass grunt task, which compiles our SASS ###
		compass:
			dev:
				options:
					sassDir: 'app/css'
					cssDir: '.tmp/css'

		### Coffee grunt task ###
		coffee:
			dist:
				files: [
					expand: true
					cwd: 'app/scripts'
					src: '**/*.coffee'
					dest: '.tmp/scripts'
					ext: '.js'
				]

		### Clean our working directories ###
		clean:
			dist: ['.tmp', 'dist']
			server: '.tmp'

		### Allows us to run multiple grunt tasks concurrently ###
		concurrent:
			options:
				logConcurrentOutput: true
			watch:
				tasks: [ 'watch:coffee', 'watch:compass', 'watch:livereload' ]

		### Initiates our server ###
		connect:
			options:
				port: options.CONNECT_PORT
				hostname: options.HOSTNAME
			livereload:
				options:
					middleware: (connect) ->
						[ lrSnippet, mountFolder(connect, '.tmp'), mountFolder(connect, 'app') ]
			dist:
				options:
					middleware: (connect) ->
						[ mountFolder(connect, 'dist') ]

		### Open our web application ###
		open:
			server: 
				path: 'http://<%= connect.options.hostname %>:<%= connect.options.port %>'

		### Minify our html ###
		htmlmin:
			dist:
				#options:
					#removeComments: true
					#collapseWhitespace: true
				files:[
					expand: true
					cwd: 'app'
					src: '*.html'
					dest: 'dist'
				]

		### Copy our relevant files to our dist directory 
		Add files here you want copied accross ###
		copy:
			dist:
				files: [
					expand: true
					dot: true
					cwd: 'app'
					dest: 'dist'
					src:[
						'*.{ico,txt}',
                    	'images/{,*/}*.{webp,gif}'
					]
				]

		### Minify our images ###
		imagemin:
			dist:
				files:[
					expand: true
					cwd: 'app/images'
					src: '{,*/}*.{png,jpg,jpeg}'
					dest: 'dist/images'
				]

		### Prepare js & css minification ###
		useminPrepare:
			html: 'app/index.html'
			options:
				dest: 'dist'
				root: '.tmp'

		usemin:
			html: 'dist/{,*/}*.html'
			css: 'dist/css/{,*/}*.css'
			options:
				dirs: 'dist'

		cssmin:
			dist: 
				options:
					keepSpecialComments: 0
					banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - 
        			<%= grunt.template.today("yyyy-mm-dd") %> */'
				src: '.tmp/css/style.css'
				dest: 'dist/css/style.css'
		concat:
			options:
				separator: ';'
				stripBanners: true
				banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - 
        			<%= grunt.template.today("yyyy-mm-dd") %> */'
		
		uglify:
			options:
				preserveComments: 'some'

		### Cache bust the bugger ###
		rev: 
			dist:
				files:
					src:[
						'dist/scripts/{,*/}*.js',
                        'dist/css/{,*/}*.css'
					]

	### Register our grunt tasks ###
	grunt.registerTask 'server', (target) ->
		if target == 'dist'
			return grunt.task.run [ 'build', 'open', 'connect:dist:keepalive' ]
		grunt.task.run [
			'clean:server'
			'coffee'
			'compass'
			'open'
			'connect:livereload'
			'concurrent:watch'
		]

	grunt.registerTask 'build', [
		'clean:dist'
		'imagemin'
		'coffee'
		'compass'
		'useminPrepare'
		'htmlmin'
		'concat'
		'uglify'
		'cssmin'
		'copy'
		'rev'
		'usemin'
	]



