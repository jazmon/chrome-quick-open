chrome.commands.onCommand.addListener((command) => {
  console.log('Command:', command);
  init();
});


function init() {
  chrome.tabs.query({
    active: true
  }, function (tabs) {
    const tabId = tabs[0].id;


    chrome.tabs.insertCSS(tabId, {
      file: 'app/build/static/css/main.f5c22ef7.css'
    })
    // chrome.tabs.insertCSS(tabId, {
    //   file: 'main.css'
    // })
    chrome.tabs.executeScript(tabId, {
      file: 'elm-import.js'
    });
    chrome.tabs.executeScript(tabId, {
      file: 'app/build/static/js/main.bd506223.js'
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
