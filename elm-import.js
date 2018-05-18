document.addEventListener('DOMContentLoaded', function () {
  const $body = document.getElementsByTagName('body')[0];
  const ROOT_TAG = '__QUICK_OPEN_ROOT';
  const $root = document.createElement('div').setAttribute('id', ROOT_TAG);
  const div = document.getElementById('body');

  div.appendChild($root);
  Elm.Main.embed($root);
});
