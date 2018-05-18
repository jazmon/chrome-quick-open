import './main.css';
import Elm from './Main.elm';
const {
  Main
} = Elm;
const app = Main.embed(document.getElementById('__QUICK_OPEN_ROOT'));

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
