var gulp = require('gulp'),
    gutil = require('gulp-util'),
    sass = require('gulp-ruby-sass'),
    haml = require('gulp-ruby-haml'),
    coffee = require('gulp-coffee'),
    watch = require('gulp-watch')

gulp.task('stylesheets', function() {
  return gulp.src('./src/stylesheets/app.scss')
    .pipe(sass({style: 'expanded'}))
    .pipe(gulp.dest('./build/stylesheets'))
})

gulp.task('javascripts', function() {
  gulp.src('./src/javascripts/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./build/javascripts'))
})

gulp.task('haml', function() {
  gulp.src('./*.haml', {read: false})
       .pipe(haml())
       .pipe(gulp.dest('./build/html'))
})

gulp.task('default', ['stylesheets', 'javascripts', 'haml'])

gulp.task('watch', function() {
  // Watch .scss files
  gulp.watch('./src/stylesheets/*.scss', ['stylesheets'])
  // Watch .js files
  gulp.watch('./src/javascripts/*.coffee', ['javascripts'])
  // Watch image files
  gulp.watch('./*.haml', ['haml'])
})
