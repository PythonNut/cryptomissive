var gulp    = require('gulp'),
    gutil   = require('gulp-util'),
    pug     = require('gulp-pug'),
    stylus  = require('gulp-stylus'),
    ts      = require('gulp-typescript'),
    postcss = require('gulp-postcss'),
    apfx    = require('autoprefixer'),
    inliner = require('gulp-inline-source');

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

gulp.task('js', function () {
  return gulp.src('source/typescript/main.ts')
    .pipe(ts({
      noImplicitAny: true,
      out: 'main.js'
    }))
    .pipe(gulp.dest('dist'));
});

gulp.task('html', ['css', 'js'], function() {
  return gulp.src('source/pug/index.pug')
    .pipe(pug({
      pretty: !gutil.env.production
    }))
    .pipe(inliner({
      rootpath: 'dist',
      compress: !!gutil.env.production,
      pretty: true
    }))
    .pipe(gulp.dest('dist'));
});

gulp.task('default', ['html'], function () {
    gutil.log("Gulp is running!");
});
