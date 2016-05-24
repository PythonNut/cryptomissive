var gulp     = require('gulp'),
    merge    = require('merge-stream'),
    gutil    = require('gulp-util'),
    watch    = require('gulp-watch'),
    concat   = require('gulp-concat'),
    pug      = require('gulp-pug'),
    stylus   = require('gulp-stylus'),
    ts       = require('gulp-typescript'),
    postcss  = require('gulp-postcss'),
    apfx     = require('autoprefixer'),
    inliner  = require('gulp-inline-source'),
    download = require('gulp-download');

var browser_sync = require('browser-sync').create();

gulp.task('css', function () {
  return gulp.src('source/stylus/main.styl')
    .pipe(stylus({
      compress: !!gutil.env.production
    }))
    .pipe(postcss([
      apfx({
      browsers: ['last 3 versions', '> 1%'],
        remove: false
      })
    ]))
    .pipe(gulp.dest('dist'));
});

gulp.task('js-source', function () {
  var libraries, main, pipes;
  libraries = [
    'https://raw.githubusercontent.com/jedisct1/libsodium.js/master/dist/browsers-sumo/combined/sodium.js',
    'https://code.jquery.com/jquery-1.12.4.min.js'];

  main = gulp.src('source/typescript/*.ts')
    .pipe(ts({
      noImplicitAny: true,
      out: 'main.js'
    }))
    .pipe(gulp.dest('dist'));

  pipes = [];
  for (var library in libraries) {
    pipes.push(download(libraries[library]).pipe(gulp.dest('lib')));
  }
  return merge.apply(this, [main].concat(pipes));
});

gulp.task('js', ['js-source'], function () {
  return gulp.src(['lib/sodium.js',
                   'lib/jquery-1.12.4.min.js',
                   'dist/main.js'])
    .pipe(concat('all.js'))
    .pipe(gulp.dest('dist'));
});

gulp.task('html', ['css', 'js'], function() {
  return gulp.src('source/pug/index.pug')
    .pipe(pug({
      pretty: !gutil.env.production
    }))
    .pipe(inliner({
      rootpath: '.',
      compress: !!gutil.env.production,
      pretty: true
    }))
    .pipe(gulp.dest('dist'));
});

gulp.task('default', ['html'], function () {
    gutil.log("Gulp is running!");
});

gulp.task('watch', function() {
  browser_sync.init({
    server: {
      baseDir: "./"
    },
    open: false
  });
  gulp.run(['default'], function () {
    gutil.log('updating browser');
    browser_sync.reload();
  });
  watch('source/**/*', function() {
    gulp.run(['default'], function () {
      gutil.log('updating browser');
      browser_sync.reload();
    });
  });
});
