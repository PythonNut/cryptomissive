fs       = require 'fs'
path     = require 'path'
gulp     = require 'gulp'
merge    = require 'merge-stream'
gutil    = require 'gulp-util'
plumber  = require 'gulp-plumber'
watch    = require 'gulp-watch'
clean    = require 'gulp-clean'
concat   = require 'gulp-concat'
pug      = require 'gulp-pug'
stylus   = require 'gulp-stylus'
ts       = require 'gulp-typescript'
postcss  = require 'gulp-postcss'
apfx     = require 'autoprefixer'
inliner  = require 'gulp-inline-source'
inline64 = require 'gulp-inline-base64'
download = require 'gulp-download-stream'
gulp-ls  = require 'gulp-livescript'

browser_sync = require 'browser-sync' .create!

gulp.task 'libs' ->
  libraries = [
    'https://raw.githubusercontent.com/jedisct1/libsodium.js/master/dist/browsers-sumo/combined/sodium.js'
    'https://raw.githubusercontent.com/necolas/normalize.css/master/normalize.css'
    'https://raw.githubusercontent.com/summernote/summernote/develop/dist/summernote.js'
    'https://raw.githubusercontent.com/summernote/summernote/develop/dist/summernote.css'
    'https://code.jquery.com/jquery-1.12.4.min.js'
    'http://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.5/css/bootstrap.min.css'
    'http://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.5/js/bootstrap.min.js'
    'https://raw.githubusercontent.com/lhorie/mithril.js/next/mithril.js'
    {
      file: 'font/summernote.eot?#iefix'
      url: 'https://github.com/summernote/summernote/raw/develop/dist/font/summernote.eot'
    }
    {
      file: 'font/summernote.eot?ad8d7e2d177d2473aecd9b35d16211fb'
      url: 'https://github.com/summernote/summernote/raw/develop/dist/font/summernote.eot'
    }
    {
      file: 'font/summernote.ttf?ad8d7e2d177d2473aecd9b35d16211fb'
      url: 'https://github.com/summernote/summernote/raw/develop/dist/font/summernote.ttf'
    }
    {
      file: 'font/summernote.woff?ad8d7e2d177d2473aecd9b35d16211fb'
      url: 'https://github.com/summernote/summernote/raw/develop/dist/font/summernote.woff'
    }
    'https://raw.githubusercontent.com/padolsey/operative/master/dist/operative.js'
  ]

  files = []
  for library in libraries
    name = library.file or library
    dir = if library.file then path.dirname library.file else ''
    unless fs.existsSync path.resolve 'lib', dir, path.basename name
      files.push(library)

  return download files, {+gzip} .pipe gulp.dest 'lib'

gulp.task 'js' ->
  return gulp.src 'source/livescript/*.ls'
    .pipe plumber!
    .pipe gulp-ls {+bare, +no-header}
    .pipe gulp.dest 'dist'

gulp.task 'css' ->
  return gulp.src 'source/stylus/*.styl'
    .pipe plumber!
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

gulp.task 'build' ['js', 'css', 'libs'] ->
  pre = gulp.src [
          'lib/jquery-1.12.4.min.js'
          'lib/mithril.js'
          'dist/model.js'
          'dist/controller.js'
          'dist/view.js'
          'dist/main.js']
    .pipe concat 'pre.js'
    .pipe gulp.dest 'dist'

  post = gulp.src [
           'lib/operative.js'
           'lib/bootstrap.min.js'
           'lib/summernote.js']
    .pipe concat 'post.js'
    .pipe gulp.dest 'dist'

  css = gulp.src [
          'lib/normalize.css'
          'lib/bootstrap.min.css'
          'lib/summernote.css'
          'dist/main.css']
    .pipe inline64 {
      baseDir: 'lib/'
      maxSize: 1000000000
      +debug
    }
    .pipe concat 'pre.css'
    .pipe gulp.dest 'dist'

  return merge(pre, post, css)

gulp.task 'html' ['build'] ->
  return gulp.src 'source/pug/index.pug'
    .pipe plumber!
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

gulp.task 'clean' ->
  lib = gulp.src 'lib', {-read}
    .pipe clean!
  dist = gulp.src 'dist', {-read}
    .pipe clean!
  merge lib, dist
