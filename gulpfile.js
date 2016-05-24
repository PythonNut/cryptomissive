var gulp    = require('gulp'),
    gutil   = require('gulp-util'),
    pug     = require('gulp-pug'),
    stylus  = require('gulp-stylus'),
    ts      = require('gulp-typescript'),
    postcss = require('gulp-postcss'),
    apfx    = require('autoprefixer');

gulp.task('default', function () {
  gutil.log("Gulp is running!");
  gulp.src('source/pug/index.pug')
    .pipe(pug({
      pretty: !gutil.env.production
    }))
    .pipe(gulp.dest('dist'));
  gulp.src('source/stylus/main.styl')
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
  gulp.src('source/typescript/main.ts')
    .pipe(ts({
      noImplicitAny: true,
      out: 'main.js'
    }))
    .pipe(gulp.dest('dist'));
});
