fs       = require 'fs'
path     = require 'path'
gulp     = require 'gulp'
merge    = require 'merge-stream'
gutil    = require 'gulp-util'
plumber  = require 'gulp-plumber'
gulp-if  = require 'gulp-if'
watch    = require 'gulp-watch'
clean    = require 'gulp-clean'
concat   = require 'gulp-concat'
pug      = require 'gulp-pug'
stylus   = require 'gulp-stylus'
postcss  = require 'gulp-postcss'
apfx     = require 'autoprefixer'
inliner  = require 'gulp-inline-source'
base64   = require 'gulp-base64'
download = require 'gulp-download-stream'
gulp-ls  = require 'gulp-livescript'
prettify = require 'gulp-jsbeautifier'
compiler = require 'gulp-closure-compiler'

browser_sync = require 'browser-sync' .create!

gulp.task 'build:libs' ->
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
      file: 'font/summernote.eot'
      url: 'https://github.com/summernote/summernote/raw/develop/dist/font/summernote.eot'
    }
    {
      file: 'font/summernote.ttf'
      url: 'https://github.com/summernote/summernote/raw/develop/dist/font/summernote.ttf'
    }
    {
      file: 'font/summernote.woff'
      url: 'https://github.com/summernote/summernote/raw/develop/dist/font/summernote.woff'
    }
    'https://raw.githubusercontent.com/padolsey/operative/master/dist/operative.js'
  ]

  files = []
  for library in libraries
    name = library.file or library
    dir = if library.file then path.dirname library.file else ''
    unless fs.exists-sync path.resolve 'lib', dir, path.basename name
      files.push library

  return download files, {+gzip} .pipe gulp.dest 'lib'

gulp.task 'build:js' ->
  return gulp.src 'source/livescript/*.ls'
    .pipe plumber!
    .pipe gulp-ls {+bare, +no-header}
    .pipe gulp.dest 'dist'

gulp.task 'build:css' ->
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

gulp.task 'build:collate' ['build:js', 'build:css', 'build:libs'] ->
  pre = gulp.src [
          'lib/jquery-1.12.4.min.js'
          'lib/mithril.js'
          'dist/model.js'
          'dist/controller.js'
          'dist/view.js'
          'dist/main.js']
    .pipe gulp-if !gutil.env.production, prettify!
    .pipe gulp-if !gutil.env.production, concat 'pre.js'
    .pipe gulp-if !!gutil.env.production, compiler {
      file-name: 'pre.js'
      +continue-with-warnings
      compiler-flags: {
        warning_level: 'QUIET'
      }
    }
    .pipe gulp.dest 'dist'

  post = gulp.src [
           'lib/operative.js'
           'lib/bootstrap.min.js'
           'lib/summernote.js']
    .pipe gulp-if !gutil.env.production, prettify!
    .pipe gulp-if !gutil.env.production, concat 'post.js'
    .pipe gulp-if !!gutil.env.production, compiler {
      file-name: 'post.js'
      +continue-with-warnings
      compiler-flags: {
        warning_level: 'QUIET'
      }
    }
    .pipe gulp.dest 'dist'

  css = gulp.src [
          'lib/normalize.css'
          'lib/bootstrap.min.css'
          'lib/summernote.css'
          'dist/main.css']
    .pipe gulp-if !gutil.env.production, prettify!
    .pipe base64 {
      base-dir: 'lib/'
      max-image-size: 1e20 # ∞
    }
    .pipe concat 'pre.css'
    .pipe gulp.dest 'dist'

  sodium = gulp.src 'lib/sodium.js'
    .pipe gulp-if !gutil.env.production, prettify!
    .pipe gulp-if !!gutil.env.production, compiler {
      file-name: 'sodium.js'
      max-buffer: 3000
      +continue-with-warnings
      compiler-flags: {
        warning_level: 'QUIET'
      }
    }
    .pipe gulp.dest 'dist'

  return merge pre, post, css, sodium

gulp.task 'build' ['build:collate'] ->
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

gulp.task 'default' ['build'] !->

gulp.task 'watch' !->
  browser_sync.init {
    server:
      * base-dir: './'
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
