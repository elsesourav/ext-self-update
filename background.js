const VERSION = chrome.runtime.getManifest().version;

async function writeLifecycle(eventName, details) {
  const lifecycle = {
    eventName,
    details,
    version: VERSION,
    at: new Date().toISOString(),
  };

  await chrome.storage.local.set({
    lifecycle,
    currentVersion: VERSION,
  });

  console.log("[self-update-test]", lifecycle);
}

chrome.runtime.onInstalled.addListener((details) => {
  void writeLifecycle("onInstalled", {
    reason: details.reason,
    previousVersion: details.previousVersion || null,
  });
});

chrome.runtime.onStartup.addListener(() => {
  void writeLifecycle("onStartup", {
    reason: "browser-start",
  });
});

chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
  if (!message || message.type !== "get-status") {
    return undefined;
  }

  chrome.storage.local
    .get(["counter", "lifecycle", "currentVersion"])
    .then((stored) => {
      sendResponse({
        version: VERSION,
        currentVersion: stored.currentVersion || VERSION,
        counter: stored.counter || 0,
        lifecycle: stored.lifecycle || null,
      });
    })
    .catch((error) => {
      sendResponse({
        version: VERSION,
        currentVersion: VERSION,
        counter: 0,
        lifecycle: null,
        error: String(error),
      });
    });

  return true;
});
