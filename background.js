chrome.commands.onCommand.addListener((command) => {
  console.log('Command:', command);
  init();
});


function init() {
  chrome.tabs.query({
    active: true
  }, function (tabs) {
    console.log('tabs[0]', tabs[0]);

    const tabId = tabs[0].id;

    chrome.tabs.insertCSS(tabId, {
      file: 'app/build/static/css/main.css'
    })
    chrome.tabs.executeScript(tabId, {
      file: 'elm-import.js'
    });
    chrome.tabs.executeScript(tabId, {
      file: 'app/build/static/js/main.js'
    });
  });
}


chrome.runtime.onInstalled.addListener(function () {
  chrome.storage.sync.set({
    color: '#3aa757'
  }, function () {
    console.log('The color is green.');
  });
});

chrome.declarativeContent.onPageChanged.removeRules(undefined, function () {
  chrome.declarativeContent.onPageChanged.addRules([{
    conditions: [new chrome.declarativeContent.PageStateMatcher({
      pageUrl: {
        hostEquals: 'developer.chrome.com'
      },
    })],
    actions: [new chrome.declarativeContent.ShowPageAction()]
  }]);
});



// recent tabs
var recentTabIds = [];

function clear(val) {
  recentTabIds.filter(item => item !== val);
  // var index = recentTabIds.indexOf(val);
  // if (index > -1) recentTabIds.splice(index, 1);
}

// tabs observers
chrome.tabs.onActivated.addListener((info) => {
  console.log('chrome.tabs.onActivated');

  clear(info.tabId);
  recentTabIds.push(info.tabId);
});

chrome.tabs.onRemoved.addListener((removedTabId) => {
  console.log('chrome.tabs.onRemoved');

  clear(removedTabId);
});

chrome.tabs.onReplaced.addListener((addedTabId, removedTabId) => {
  console.log('chrome.tabs.onReplaced');
  clear(removedTabId);
  clear(addedTabId);
  recentTabIds.push(addedTabId);
});

function getRecentTabs(callback) {
  var n = recentTabIds.length
  var j = 0,
    tabs = [];
  if (n < 2) return callback([]);
  for (var i = n - 2; i >= 0; i--) {
    chrome.tabs.get(recentTabIds[i], (tab) => {
      if (tab) tabs.push(tab);
      if (j === (n - 2)) return callback(tabs);
      j++;
    });
  };
}

// message comunication
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  console.log('chrome.runtime.onMessage', msg);

  if (msg.action === 'activate_tab') {
    chrome.tabs.update(msg.data.tab.id, {
      selected: true
    });
  }
  if (msg.action === 'get_all_tabs') {
    chrome.tabs.query({}, (tabs) => {
      msg.data = tabs;
      chrome.tabs.sendMessage(sender.tab.id, msg);
    });
  }
  if (msg.action === 'get_recent_tabs') {
    getRecentTabs((tabs) => {
      msg.data = tabs;
      chrome.tabs.sendMessage(sender.tab.id, msg);
    });
  }
});
