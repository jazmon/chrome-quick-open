const $body = document.getElementsByTagName('body')[0];
const ROOT_TAG = '__QUICK_OPEN_ROOT';
const $root = document.createElement('div');
$root.setAttribute('id', ROOT_TAG);

console.log('ROOT_TAG', ROOT_TAG);

// console.log('Elm', window.Elm);
// console.log('Main', window.Main)
$body.appendChild($root);
// Elm.Main.embed($root);
// document.addEventListener('DOMContentLoaded', function () {
// });
