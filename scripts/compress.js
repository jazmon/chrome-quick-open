const fs = require('fs');
const path = require('path');
const shell = require('shelljs');
const ChromeExtension = require('crx');

const name = require('../manifest.json').name;


const baseDir = (filePath, ...args) => path.resolve(__dirname, '..', filePath, ...args);

const paths = {
  buildDir: baseDir('build'),
  manifest: baseDir('manifest.json'),
  backgroundScript: baseDir('background.js'),
  contentScript: baseDir('app/build/static/js/main.js'),
  contentCSS: baseDir('app/build/static/css/main.css'),
}


console.log('paths', paths);

shell.rm('-r', buildDir);
shell.mkdir(buildDir);



// fs.copyFileSync(path.resolve(__dirname, '../manifest.json'), destDir);
