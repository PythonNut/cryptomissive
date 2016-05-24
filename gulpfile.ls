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
download = require 'gulp-download'
gulp-ls  = require 'gulp-livescript'

browser_sync = require 'browser-sync' .create!

gulp.task 'css' ->
  gulp.src 'source/stylus/main.styl'
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

gulp.task 'js-source' ->
  libraries = [
    'https://raw.githubusercontent.com/jedisct1/libsodium.js/master/dist/browsers-sumo/combined/sodium.js'
    'https://code.jquery.com/jquery-1.12.4.min.js'
  ]

  main = gulp.src 'source/livescript/*.ls'
    .pipe gulp-ls {
      +bare
    }
    .pipe gulp.dest 'dist'

  pipes = []
  for library in libraries
    pipes.push(download library .pipe gulp.dest 'lib')

  merge.apply @, [main].concat pipes

gulp.task 'js' ['js-source'] ->
  gulp.src ['lib/sodium.js'
            'lib/jquery-1.12.4.min.js'
            'dist/main.js']
    .pipe concat 'all.js'
    .pipe gulp.dest 'dist'

gulp.task 'html' ['css' 'js'] ->
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
