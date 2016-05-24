var gulp     = require('gulp'),
    merge    = require('merge-stream'),
    gutil    = require('gulp-util'),
    concat   = require('gulp-concat'),
    pug      = require('gulp-pug'),
    stylus   = require('gulp-stylus'),
    ts       = require('gulp-typescript'),
    postcss  = require('gulp-postcss'),
    apfx     = require('autoprefixer'),
    inliner  = require('gulp-inline-source'),
    download = require('gulp-download');

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
  var sodium, main;
  sodium = download('https://raw.githubusercontent.com/jedisct1/libsodium.js/master/dist/browsers/combined/sodium.js')
    .pipe(gulp.dest('lib'));
  main = gulp.src('source/typescript/main.ts')
    .pipe(ts({
      noImplicitAny: true,
      out: 'main.js'
    }))
    .pipe(gulp.dest('dist'));
  return merge(sodium, main);
});

gulp.task('js', ['js-source'], function () {
  return gulp.src(['lib/sodium.js', 'dist/main.js'])
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
