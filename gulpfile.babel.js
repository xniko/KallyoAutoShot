'use strict';

const path = require('path');
const gulp = require('gulp');
const del = require('del');
const runSequence = require('run-sequence');
const gulpLoadPlugins = require('gulp-load-plugins');
const pkg = require('./package.json');

const $ = gulpLoadPlugins();

// Concatenate lua files
gulp.task('concat', () =>
  gulp.src([
    'src/_globals.lua',
    'src/_create_UI.lua',
    'src/style2.lua',
    'src/_registerEvents.lua',
    'src/_utils.lua',
    'src/**/*.lua',
    '!src/menu.lua',
    '!src/_registerEvents.lua'
  ])
    .pipe($.concat('KallyoAutoShot.lua'))
    .pipe(gulp.dest('./'))
);

// Lint lua files
gulp.task('lint', function() {
    return gulp
        .src('KallyoAutoShot.lua')
        .pipe($.luacheck())
        .pipe($.luacheck.reporter('stylish'))
});

// Watch task
gulp.task('watch',['concat'], () =>
    gulp.watch('src/**/*.lua' , ['lint','concat'])
);

// Clean output directory
gulp.task('clean', () => del(['KallyoAutoShot.lua', 'dist/*', '!dist/.git'], {dot: true}));

gulp.task('default', ['clean','concat', 'watch']);
