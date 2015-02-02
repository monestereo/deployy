require('coffee-script/register')
app = process.argv.slice(2)[0]
shell = require 'shelljs'
config = require './config.json'
path = require 'path'
procfile = require 'procfile'
pm2 = require 'pm2'
appDir = path.join config.apps.path, app
utils = require './lib/utils'
fs = require 'fs'
nginx = require './lib/nginx'
_ = require 'lodash'
node = require './builders/node-builder' # TODO: wildcard require and extra node_modules

# pull
shell.echo "updating application"
shell.exec 'GIT_WORK_TREE=' + appDir + ' git checkout -f'

procfileLocation = path.join(appDir, 'Procfile')
if fs.existsSync(procfileLocation)
	shell.echo "Procfile detected"
	proc = procfile.parse(fs.readFileSync(procfileLocation, 'utf8'))
	
	###
	{ web: { command: 'node', options: [ 'app.js' ] } }
	###
	if proc.web?
		shell.echo "type Web detected"
		appsData = utils.getAppsData()
		app = _.find(appsData.apps, {name: app})
		if proc.web.command is 'node'
			if not app.configPath?
				configPath = nginx.createConfig(app)
				app.configPath = configPath
				utils.saveAppsData()
				nginx.restart()

			node.stop(app)
				.then ()->
					return node.init(app)
				.then () ->
					return node.start(app, proc.web.options)
				.then () ->
					shell.echo('successfully started application... visit: http://' + app.name + '.' + config.server.domain);
				.catch (err)->
					console.log err
