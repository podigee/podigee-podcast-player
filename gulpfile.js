var gulp = require('gulp'),
    gutil = require('gulp-util'),
    sass = require('gulp-sass'),
    coffee = require('gulp-coffee'),
    watch = require('gulp-watch'),
    uglify = require('gulp-uglify'),
    concat = require('gulp-concat'),
    browserify = require('gulp-browserify'),
    rename = require('gulp-rename'),
    connect = require('gulp-connect');
    gzip = require('gulp-gzip');
    fs = require('fs');
    s3 = require('gulp-s3');

var dest = './dist';
var paths = {
  main_stylesheet: ['./src/stylesheets/app.scss'],
  stylesheets: ['./src/stylesheets/*.scss'],
  main_javascript: ['./src/javascripts/app.coffee'],
  javascripts: ['./src/javascripts/**/*.coffee'],
  html: ['./src/html/podigee-podcast-player.html', './src/html/embed-example.html'],
  images: ['./src/images/**'],
  fonts: ['./src/fonts/**', './vendor/fonts/**'],
  themes: {
    html: ['./src/themes/**/index.html'],
    css: ['./src/themes/**/*.scss']
  }
};

gulp.task('stylesheets', function() {
  return gulp.src(paths.main_stylesheet)
    .pipe(sass({style: 'compressed'}))
    .pipe(gulp.dest('./build/stylesheets'))
    .pipe(gzip())
    .pipe(gulp.dest('./build/stylesheets'))
})

gulp.task('stylesheets-dev', function() {
  return gulp.src(paths.main_stylesheet)
    .pipe(sass())
    .pipe(gulp.dest('./build/stylesheets'))
    .pipe(connect.reload())
})

gulp.task('javascripts', function() {
  gulp.src(paths.main_javascript, {read: false})
    .pipe(browserify({
      transform: ['coffeeify'],
      extensions: ['.coffee']
    }))
    .pipe(uglify())
    .pipe(rename('podigee-podcast-player.js'))
    .pipe(gulp.dest('./build/javascripts'))
    .pipe(gzip())
    .pipe(gulp.dest('./build/javascripts'))
})

gulp.task('javascripts-dev', function() {
  gulp.src(paths.main_javascript, {read: false})
    .pipe(browserify({
      transform: ['coffeeify'],
      extensions: ['.coffee']
    }))
    .pipe(rename('podigee-podcast-player.js'))
    .pipe(gulp.dest('./build/javascripts'))
    .pipe(connect.reload())
})

gulp.task('html', function() {
  gulp.src(paths.html)
    .pipe(gulp.dest('./build'))
    .pipe(connect.reload())
})

gulp.task('images', function() {
  gulp.src(paths.images)
    .pipe(gulp.dest('./build/images'))
    .pipe(connect.reload())
})

gulp.task('fonts', function() {
  gulp.src(paths.fonts)
    .pipe(gulp.dest('./build/fonts'))
    .pipe(connect.reload())
})

gulp.task('themes', function() {
  gulp.src(paths.themes.html)
    .pipe(gulp.dest('./build/themes'))
    .pipe(connect.reload())

  gulp.src(paths.themes.css)
    .pipe(sass({style: 'compressed'}))
    .pipe(gulp.dest('./build/themes'))
    .pipe(connect.reload())
})

gulp.task('default', [
  'stylesheets',
  'javascripts',
  'html',
  'images',
  'fonts',
  'themes'
])

gulp.task('dev', [
  'stylesheets-dev',
  'javascripts-dev',
  'html',
  'images',
  'fonts',
  'themes'
])

gulp.task('watch', function() {
  gulp.watch(paths.stylesheets, ['stylesheets-dev'])
  gulp.watch(paths.javascripts, ['javascripts-dev'])
  gulp.watch(paths.html, ['html'])
  gulp.watch(paths.images, ['images'])
  gulp.watch(paths.themes.html, ['themes'])
  gulp.watch(paths.themes.css, ['themes'])
})

gulp.task('connect', function() {
  connect.server({
    host: '0.0.0.0',
    root: [__dirname],
    livereload: true
  });
});

gulp.task('upload', ['default'], function() {
  awsCredentials = JSON.parse(fs.readFileSync('./aws.json'))
  return gulp.src('build/**')
    .pipe(s3(awsCredentials, {
      uploadPath: "/podcast-player/",
      headers: {'x-amz-acl': 'public-read'}
    }))
})

gulp.task('deploy', ['upload'])

// Serve
gulp.task('serve', ['connect', 'watch']);
