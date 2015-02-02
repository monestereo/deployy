config = require '../config.json'
_ = require 'lodash'
fs = require 'fs'
path = require 'path'
shell = require 'shelljs'

createConfig = (appConf)->
	# generate nginx config
	nginxTemplate = fs.readFileSync('templates/nginx.conf', 'utf8')
	rendered = _.template(nginxTemplate)(_.extend(appConf, domain: config.server.domain))
	
	# write nginx config
	availablePath = path.join config.apps.path, 'sites-available'
	enabledPath = path.join config.apps.path, 'sites-enabled'

	if not fs.existsSync availablePath
		shell.mkdir availablePath
	if not fs.existsSync enabledPath
		shell.mkdir enabledPath

	configPath = path.join(availablePath, appConf.name + '.conf')
	fs.writeFileSync configPath, rendered, encoding: 'utf8'

	# link nginx config to sites-enabled
	fs.symlinkSync configPath, path.join(enabledPath, appConf.name + '.conf')

	return configPath: configPath

restart = ()->
	shell.exec('sudo /etc/init.d/nginx restart')

module.exports = 
	createConfig: createConfig,
	restart: restart