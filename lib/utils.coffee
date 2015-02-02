fs = require 'fs'
config = require '../config.json'
_ = require 'lodash'
moniker = require('moniker')
names = moniker.generator([
	moniker.adjective
	moniker.noun
])
path = require 'path'

data = null
dataDbPath = path.join(__dirname, '..', 'data.db')

init = ->
	if not fs.existsSync(dataDbPath)
		console.log('create Data File')
		data =
			'apps': []
			'port': config.apps.ports
	else
		console.log('read Data File')
		data = JSON.parse(fs.readFileSync(dataDbPath, 'utf8'))

saveAppsData = ()->
	fs.writeFileSync dataDbPath, JSON.stringify(data, null, 4), encoding: 'utf8'

uniqueServerName = ->
	appname = names.choose()
	if _.find(data.apps, name: appname)
		uniqueServerName()
	else
		appname

uniquePort = ->
	data.port++
	return data.port

getAppsData = -> data

addApp = (appConf)->
	data.apps.push appConf
	saveAppsData()

module.exports = 
	uniqueServerName: uniqueServerName
	uniquePort: uniquePort
	getAppsData: getAppsData
	addApp: addApp
	saveAppsData: saveAppsData
	init: init
