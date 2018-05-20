import './main.css';
import {
  Main
} from './Main.elm';

const ROOT_TAG = '__QUICK_OPEN_ROOT';

const actions = {
  GET_ALL_TABS: 'get_all_tabs',
  GET_RECENT_TABS: 'get_recent_tabs',
  ACTIVATE_TAB: 'activate_tab'
}

// If the root tag doesn't exist, create it
if (!document.getElementById(ROOT_TAG)) {
  const $body = document.getElementsByTagName('body')[0];
  const $root = document.createElement('div');

  $root.setAttribute('id', ROOT_TAG);
  $body.appendChild($root);
}

let app;

// If the root tag has no content, mount the elm app
if (document.getElementById(ROOT_TAG).innerHTML === '') {
  app = Main.embed(document.getElementById(ROOT_TAG), {
    environment: process.env.NODE_ENV || 'production'
  });
  // send a message immediately to get all tabs
  chrome.runtime.sendMessage({
    action: actions.GET_ALL_TABS
  });
}

// Add listeners for get tab actions
chrome.runtime.onMessage.addListener((msg) => {
  if (msg.action === actions.GET_ALL_TABS) {

    const tabs = msg.data.map(tab => Object.assign({}, tab, {
      favIconUrl: tab.favIconUrl || ''
    }));

    app.ports.receiveTabs.send(tabs, 'all');
  } else if (msg.action === actions.GET_RECENT_TABS) {

    const tabs = msg.data.map(tab => Object.assign({}, tab, {
      favIconUrl: tab.favIconUrl || ''
    }));

    app.ports.receiveTabs.send(msg.data, 'recent');
  }
});

// listen for activate tab commands
app.ports.activateTab.subscribe((tab) => {
  document.getElementById(ROOT_TAG).innerHTML = '';
  // If no tab, just delete the view
  if (tab === null) return;
  // otherwise go to the tab
  chrome.runtime.sendMessage({
    action: actions.ACTIVATE_TAB,
    data: {
      tab: tab
    }
  });
})

// Not used yet. Could be used to pass get tabs messages from elm app to chrome
app.ports.getTabs.subscribe((tabsType) => {
  if (tabsType === 'all') {
    chrome.runtime.sendMessage({
      action: actions.GET_ALL_TABS
    });
  } else if (tabsType === 'recent') {
    chrome.runtime.sendMessage({
      action: actions.GET_RECENT_TABS
    });
  }
})
