utils = require './utils'
path = require 'path'
config = require '../config.json'
shell = require 'shelljs'
fs = require 'fs'
_ = require 'lodash'

initRepo = ->
	uniqueName = utils.uniqueServerName()

	# create Config
	appConf = 
		name: uniqueName
		path: path.join(config.apps.path, uniqueName)
		port: utils.uniquePort()

	# create git Repo
	repoPath = path.join(config.apps.path, 'repositories', uniqueName + '.git')
	shell.exec 'git init --bare ' + repoPath, silent: yes
	shell.exec 'git clone -q ' + repoPath + ' ' + appConf.path, silent: yes
	
	# add post-receive hook
	postRecieveTemplate = fs.readFileSync('templates/post-recieve.tmpl', 'utf8')
	postRecieve = _.template(postRecieveTemplate)(
		nodePath: config.builder.node.nodePath
		scriptPath: path.join(__dirname, '../', 'updateApp.js')
		app: uniqueName
	)

	hookPath = path.join(repoPath, 'hooks', 'post-receive')
	fs.writeFileSync hookPath, postRecieve, encoding: 'utf8'
	shell.chmod '+x', hookPath

	utils.addApp(appConf)

	console.log "successfully created: #{uniqueName}"
	return

module.exports = {
	initRepo: initRepo
}