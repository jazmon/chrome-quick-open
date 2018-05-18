import './main.css';
import Elm from './Main.elm';
const {
  Main
} = Elm;

const ROOT_TAG = '__QUICK_OPEN_ROOT';


if (!document.getElementById(ROOT_TAG)) {
  const $body = document.getElementsByTagName('body')[0];
  const $root = document.createElement('div');
  $root.setAttribute('id', ROOT_TAG);
  $body.appendChild($root);
}

let app;

if (document.getElementById(ROOT_TAG).innerHTML === '') {
  app = Main.embed(document.getElementById(ROOT_TAG));
}

console.log('app', app);


console.log('foo')

console.log('chrome', chrome)
console.log('Main', Main);

console.log('Elm', Elm);

console.log('Main.ports', Main.ports);



// global.Main = window.Main = Main;

chrome.runtime.sendMessage({
  action: 'get_all_tabs'
});

chrome.runtime.onMessage.addListener(function (msg) {
  if (msg.action === 'get_all_tabs') {
    // self.tabs = msg.data;
    app.ports.receiveTabs.send(msg.data, 'all');
  }
  if (msg.action === 'get_recent_tabs') {
    app.ports.receiveTabs.send(msg.data, 'recent');
    // self.recentTabs = msg.data;
    // self.search();
  }
});
app.ports.activateTab.subscribe((tab) => {
  // If no tab, just delete the view
  if (tab === null) return document.getElementById(ROOT_TAG).innerHTML = '';
  chrome.runtime.sendMessage({
    action: 'activate_tab',
    data: {
      tab: tab
    }
  });
})


app.ports.getTabs.subscribe((tabsType) => {
  if (tabsType === 'all') {
    chrome.runtime.sendMessage({
      action: 'get_all_tabs'
    });
  } else if (tabsType === 'recent') {
    chrome.runtime.sendMessage({
      action: 'get_recent_tabs'
    });
  }
})
// setTimeout(() => {


// }, 0);


// chrome.runtime.sendMessage({ action: 'activate_tab', data: {tab: tab} });

// chrome.runtime.sendMessage({ action: 'get_all_tabs' });
// chrome.runtime.sendMessage({ action: 'get_recent_tabs' });
