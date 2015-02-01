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
	configPath = path.join(config.server.availableDir, appConf.name + '.conf')
	fs.writeFileSync configPath, rendered, encoding: 'utf8'

	# link nginx config to sites-enabled
	fs.symlinkSync configPath, path.join(config.server.enabledDir, appConf.name + '.conf')

	return configPath: configPath



restart = ()->
	shell.exec(config.server.restartCmd)

module.exports = 
	createConfig: createConfig,
	restart: restart