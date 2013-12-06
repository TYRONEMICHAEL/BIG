# Initiate application
((global, doc) ->
	app = global.app =
		init: ->
			console.log 'BIG welcomes you.'
	app.init()
)(window, document)