shell = require 'shelljs'
nginx = require '../lib/nginx'
path = require 'path'
fs = require 'fs'
config = require '../config.json'
pm2 = require 'pm2'
q = require 'q'
_ = require 'lodash'

init = (app)->
	deferred = q.defer()
	
	shell.cd(app.path)
	
	if not fs.existsSync(path.join(app.path, 'package.json'))
		shell.echo 'no package.json file detected... skipping npm install'
		return
	
	# npm install
	shell.exec config.builder.node.npmPath + ' install', async: yes, (code, output) ->
		deferred.resolve()

	deferred.promise

start = (app, args) ->
	deferred = q.defer()
	pm2.connect (err) ->
		return deferred.reject(err) if err
		pm2.start(
			path.join(app.path, args.shift()),
			_.extend({name: app.name, scriptArgs: args }, config.builder.node.npmPath), 
			(err, proc) ->
				return deferred.reject(err) if err
				pm2.describe app.name, (err, proc) ->
					return deferred.reject(err) if err
					pm2.disconnect ->
						deferred.resolve(proc)
		)
	deferred.promise

stop = (app) ->
	deferred = q.defer()
	pm2.connect (err) ->
		return deferred.reject(err) if err
		pm2.stop app.name, (err, proc) ->
			return deferred.reject(err) if err
			pm2.describe app.name, (err, proc) ->
				return deferred.reject(err) if err
				pm2.disconnect ->
					deferred.resolve(proc)
	deferred.promise	

module.exports = 
	init: init
	start: start
	stop: stop