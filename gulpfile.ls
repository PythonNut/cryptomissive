fs       = require 'fs'
path     = require 'path'
gulp     = require 'gulp'
merge    = require 'merge-stream'
gutil    = require 'gulp-util'
watch    = require 'gulp-watch'
concat   = require 'gulp-concat'
pug      = require 'gulp-pug'
stylus   = require 'gulp-stylus'
ts       = require 'gulp-typescript'
postcss  = require 'gulp-postcss'
apfx     = require 'autoprefixer'
inliner  = require 'gulp-inline-source'
download = require 'gulp-download-stream'
gulp-ls  = require 'gulp-livescript'

browser_sync = require 'browser-sync' .create!

gulp.task 'libs' ->
  libraries = [
    'https://raw.githubusercontent.com/jedisct1/libsodium.js/master/dist/browsers-sumo/combined/sodium.js'
    'https://code.jquery.com/jquery-1.12.4.min.js'
  ]

  pipes = []
  for library in libraries
    unless fs.existsSync path.resolve 'lib', path.basename library
      pipes.push(download library, {+gzip} .pipe gulp.dest 'lib')

  stream = merge.apply @, pipes
  stream.isEmpty! ? null : stream

gulp.task 'js' ['libs'] ->
  return gulp.src 'source/livescript/*.ls'
    .pipe gulp-ls {+bare, +no-header}
    .pipe gulp.dest 'dist'

gulp.task 'css' ['libs'] ->
  return gulp.src 'source/stylus/*.styl'
    .pipe stylus {
      compress: !!gutil.env.production
    }
    .pipe postcss [
      apfx {
        browsers: ['last 3 versions' '> 1%']
        -remove
      }
    ]
    .pipe gulp.dest 'dist'

gulp.task 'build' ['js', 'css'] ->
  pre = gulp.src [
          'lib/jquery-1.12.4.min.js'
          'dist/main.js']
    .pipe concat 'pre.js'
    .pipe gulp.dest 'dist'

  post = gulp.src [
           'lib/sodium.js'
           'lib/tinymce.min.js']
    .pipe concat 'post.js'
    .pipe gulp.dest 'dist'

  merge(pre, post)

gulp.task 'html' ['build'] ->
  gulp.src 'source/pug/index.pug'
    .pipe pug {
      pretty: !gutil.env.production
    }
    .pipe inliner {
      rootpath: '.'
      compress: !!gutil.env.production
      +pretty
    }
    .pipe gulp.dest 'dist'

gulp.task 'default' ['html'] !->
  gutil.log 'Gulp is running!'

gulp.task 'watch' !->
  browser_sync.init {
    server:
      * baseDir: "./"
    -open
  }

  gulp.run ['default'] !->
    gutil.log 'updating browser'
    browser_sync.reload!

  watch 'source/**/*' !->
    gulp.run ['default'] !->
      gutil.log 'updating browser'
      browser_sync.reload!
