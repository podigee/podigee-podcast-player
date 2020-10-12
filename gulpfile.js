var gulp = require('gulp'),
  gutil = require('gulp-util'),
  sass = require('gulp-sass'),
  watch = require('gulp-watch'),
  uglify = require('gulp-uglify-es').default,
  concat = require('gulp-concat'),
  browserify = require('gulp-browserify'),
  rename = require('gulp-rename'),
  connect = require('gulp-connect'),
  gzip = require('gulp-gzip'),
  fs = require('fs'),
  inject = require('gulp-inject')

var dest = './build'
var paths = {
  main_stylesheet: [
    './src/stylesheets/app.scss',
    './src/stylesheets/app-direct.scss',
  ],
  stylesheets: ['./src/stylesheets/*.scss'],
  embed_javascript: ['./src/javascripts/app.coffee'],
  main_javascript: ['./src/javascripts/embed.coffee'],
  direct_javascript: ['./src/javascripts/direct.coffee'],
  javascripts: ['./src/javascripts/**/*.coffee'],
  html: [
    './src/html/podigee-podcast-player.html',
    './src/html/podigee-podcast-player-direct.html',
  ],
  images: ['./src/images/**'],
  fonts: ['./src/fonts/**', './vendor/fonts/**'],
  themes: {
    html: ['./src/themes/**/index.html'],
    css: ['./src/themes/**/index.scss'],
    css_all: ['./src/themes/**/*.scss'],
    images: ['./src/themes/**/*.png', './src/themes/**/*.jpg'],
    fonts: ['./src/themes/*/fonts/**'],
  },
}

var getVersion = function() {
  return require('child_process')
    .execSync('git rev-parse HEAD')
    .toString()
    .trim()
    .substring(0, 5)
}

gulp.task('stylesheets', function() {
  return gulp
    .src(paths.main_stylesheet)
    .pipe(sass({ style: 'compressed' }))
    .pipe(gulp.dest(dest + '/stylesheets'))
    .pipe(gzip())
    .pipe(gulp.dest(dest + '/stylesheets'))
})

gulp.task('stylesheets-dev', function() {
  return gulp
    .src(paths.main_stylesheet)
    .pipe(sass())
    .pipe(gulp.dest(dest + '/stylesheets'))
    .pipe(connect.reload())
})

gulp.task('javascripts', function() {
  gulp
    .src(paths.main_javascript, { read: false })
    .pipe(
      browserify({
        transform: ['coffeeify'],
        extensions: ['.coffee'],
      })
    )
    .pipe(uglify())
    .pipe(rename('podigee-podcast-player.js'))
    .pipe(gulp.dest(dest + '/javascripts'))
    .pipe(gzip())
    .pipe(gulp.dest(dest + '/javascripts'))

  gulp
    .src(paths.direct_javascript, { read: false })
    .pipe(
      browserify({
        transform: ['coffeeify'],
        extensions: ['.coffee'],
      })
    )
    .pipe(uglify())
    .pipe(rename('podigee-podcast-player-direct.js'))
    .pipe(gulp.dest(dest + '/javascripts'))
    .pipe(gzip())
    .pipe(gulp.dest(dest + '/javascripts'))

  return gulp
    .src(paths.embed_javascript, { read: false })
    .pipe(
      browserify({
        transform: ['coffeeify'],
        extensions: ['.coffee'],
      })
    )
    .pipe(uglify())
    .pipe(rename('podigee-podcast-player-embed.js'))
    .pipe(gulp.dest(dest + '/javascripts'))
    .pipe(gzip())
    .pipe(gulp.dest(dest + '/javascripts'))
})

gulp.task('javascripts-dev', async function() {
  return Promise.all([
    gulp
      .src(paths.main_javascript, { read: false })
      .pipe(
        browserify({
          transform: ['coffeeify'],
          extensions: ['.coffee'],
        })
      )
      .pipe(rename('podigee-podcast-player.js'))
      .pipe(gulp.dest(dest + '/javascripts'))
      .pipe(connect.reload()),

    gulp
      .src(paths.direct_javascript, { read: false })
      .pipe(
        browserify({
          transform: ['coffeeify'],
          extensions: ['.coffee'],
        })
      )
      .pipe(rename('podigee-podcast-player-direct.js'))
      .pipe(gulp.dest(dest + '/javascripts'))
      .pipe(connect.reload()),

    gulp
      .src(paths.embed_javascript, { read: false })
      .pipe(
        browserify({
          transform: ['coffeeify'],
          extensions: ['.coffee'],
        })
      )
      .pipe(rename('podigee-podcast-player-embed.js'))
      .pipe(gulp.dest(dest + '/javascripts'))
      .pipe(connect.reload()),
  ])
})

gulp.task(
  'html',
  gulp.series('javascripts', 'stylesheets', function() {
    return gulp
      .src(paths.html)
      .pipe(
        inject(gulp.src([dest + '/stylesheets/app.css'], { read: true }), {
          starttag: '<!-- inject:head:{{ext}} -->',
          transform: function (filePath, file) {
            var fileContents = file.contents.toString('utf8')
            fileContents = fileContents.replace('url("../', 'url("')
            return '<style>' + fileContents + '</style>'
          },
        })
      )
      .pipe(
        inject(
          gulp.src([dest + '/javascripts/podigee-podcast-player-embed.js'], {
            read: true,
          }),
          {
            starttag: '<!-- inject:head:{{ext}} -->',
            transform: function (filePath, file) {
              var fileContents = file.contents.toString('utf8')
              return '<script>' + fileContents + '</script>'
            },
          }
        )
      )
      .pipe(
        inject(
          gulp.src([dest + '/javascripts/podigee-podcast-player-embed.js'], {
            read: true,
          }),
          {
            starttag: '<!-- inject:head:version -->',
            transform: function (filePath, file) {
              return '<script>window.VERSION = "' + getVersion() + '"</script>'
            },
          }
        )
      )
      .pipe(gulp.dest(dest))
      .pipe(connect.reload())
  })
)

gulp.task('html-dev', function () {
  return gulp.src(paths.html).pipe(gulp.dest(dest)).pipe(connect.reload())
})

gulp.task('images', function() {
  return gulp
    .src(paths.images)
    .pipe(gulp.dest(dest + '/images'))
    .pipe(connect.reload())
})

gulp.task('fonts', function() {
  return gulp
    .src(paths.fonts)
    .pipe(gulp.dest(dest + '/fonts'))
    .pipe(connect.reload())
})

gulp.task('themes', function() {
  gulp
    .src(paths.themes.html)
    .pipe(gulp.dest(dest + '/themes'))
    .pipe(connect.reload())

  gulp
    .src(paths.themes.fonts)
    .pipe(gulp.dest('./build/themes'))
    .pipe(connect.reload())

  gulp
    .src(paths.themes.images)
    .pipe(gulp.dest(dest + '/themes'))
    .pipe(connect.reload())

  return gulp
    .src(paths.themes.css)
    .pipe(sass({ style: 'compressed' }))
    .pipe(gulp.dest(dest + '/themes'))
    .pipe(connect.reload())
})

gulp.task(
  'build',
  gulp.series('stylesheets', 'javascripts', 'html', 'images', 'fonts', 'themes')
)

gulp.task('default', gulp.series('build'))

gulp.task(
  'dev',
  gulp.series(
    'stylesheets-dev',
    'javascripts-dev',
    'html-dev',
    'images',
    'fonts',
    'themes'
  )
)

var cors = function (_, res, next) {
  res.setHeader('Access-Control-Allow-Origin', '*')
  next()
}

gulp.task('watch', function() {
  gulp.watch(paths.stylesheets, gulp.series('stylesheets-dev'))
  gulp.watch(paths.javascripts, gulp.series('javascripts-dev'))
  gulp.watch(paths.html, gulp.series('html-dev'))
  gulp.watch(paths.images, gulp.series('images'))
  gulp.watch(paths.themes.html, gulp.series('themes'))
  gulp.watch(paths.themes.css_all, gulp.series('themes'))
  gulp.watch(paths.themes.images, gulp.series('themes'))
})

gulp.task('connect', function() {
  connect.server({
    host: '0.0.0.0',
    port: 8081,
    root: [__dirname],
    livereload: true,
    middleware: () => [cors],
  })
})

// Serve
gulp.task('serve', gulp.parallel('connect', 'dev', 'watch'))
