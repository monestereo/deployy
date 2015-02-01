require('coffee-script/register')

var git = require('./lib/git');
var gulp = require('gulp');

gulp.task('create', function(){
	git.initRepo()	
});
