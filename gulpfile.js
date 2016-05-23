var gulp  = require('gulp'),
    gutil = require('gulp-util'),
    pug   = require('gulp-pug');

gulp.task('default', function () {
  gutil.log("Gulp is running!");
  gulp.src('source/pug/index.pug')
    .pipe(pug({
      pretty: !gutil.env.production
    }))
    .pipe(gulp.dest('dist'));
});
