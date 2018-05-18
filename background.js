chrome.commands.onCommand.addListener(command => {
  init();
});

const init = () => {
  chrome.tabs.query({
      active: true,
    },
    (tabs) => {
      const tabId = tabs[0].id;

      chrome.tabs.insertCSS(tabId, {
        file: 'app/build/static/css/main.css',
      });
      chrome.tabs.executeScript(tabId, {
        file: 'app/build/static/js/main.js',
      });
    },
  );
};

// recent tabs
let recentTabIds = [];

function removeRecentTab(val) {
  recentTabIds.filter(item => item !== val);
  // const index = recentTabIds.indexOf(val);
  // if (index > -1) recentTabIds.splice(index, 1);
}

// tabs observers
chrome.tabs.onActivated.addListener(info => {
  removeRecentTab(info.tabId);
  recentTabIds.push(info.tabId);
});

chrome.tabs.onRemoved.addListener(removedTabId => {
  removeRecentTab(removedTabId);
});

chrome.tabs.onReplaced.addListener((addedTabId, removedTabId) => {
  removeRecentTab(removedTabId);
  removeRecentTab(addedTabId);
  recentTabIds.push(addedTabId);
});

// No idea how this works
const getRecentTabs = callback => {
  let length = recentTabIds.length;
  let j = 0;
  let tabs = [];

  if (length < 2) return callback([]);
  for (let i = length - 2; i >= 0; i--) {
    chrome.tabs.get(recentTabIds[i], tab => {
      if (tab) tabs.push(tab);
      if (j === length - 2) return callback(tabs);
      j++;
    });
  }
};

// message comunication
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  if (msg.action === 'activate_tab') {
    chrome.tabs.update(msg.data.tab.id, {
      selected: true,
    });
  } else if (msg.action === 'get_all_tabs') {
    chrome.tabs.query({}, tabs => {
      msg.data = tabs;
      chrome.tabs.sendMessage(sender.tab.id, msg);
    });
  } else if (msg.action === 'get_recent_tabs') {
    getRecentTabs(tabs => {
      msg.data = tabs;
      chrome.tabs.sendMessage(sender.tab.id, msg);
    });
  }
});
