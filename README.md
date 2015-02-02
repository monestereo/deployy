## Deployy

## WIP (don't use yet)

this is a Heroku-like git-push-deployment script without Containers and VMs

this will essentially:
- create an empty git repository with a cool name
- setup an post-receive-hook
- on push: 
	- pull the new version 
	- create nginx-config if it doesnt exist
	- read the Procfile
	- stop the app
	- npm install
	- start the app

the running processes are managed with pm2.

### config
```
{
	"apps": {
		"path": "/path/to/your/apps", -> the apps and repositories will go there.. this should be a low-priviledged users home or so. apps will run under this user
		"ports": "80000" -> the Starting point for Port selection.. should be a highport
	},
	"server": {
		"domain": "example.com",
		"restartCmd": "/etc/init.d/nginx restart"
	},
	"builder": {
		"node": {
			"nodePath": "/usr/local/bin/node",
			"npmPath": "/usr/local/bin/npm",
			"pm2": {} -> additional pm2 options # todo: link documentation
		}
	}
}
```

### setup
allow the user using deployy to restart nginx without password (TODO: is there a more secure way?):
create the file /etc/sudoers.d/your_username with the content `your_user ALL=NOPASSWD:/etc/init.d/nginx`

add the line `include /path/to/your/apps/sites-enabled/*.conf;` to /etc/nginx/nginx.conf right after the line `include /etc/nginx/sites-enabled/*;`

### usage

`gulp create` on the server will create the repository

the git repo will then be in /path/to/your/apps/repositories/app-name.git

on the client: 
`git remote add deployy ssh://user@server:/path/to/your/apps/repositories/app-name.git`
`git push deployy master`
