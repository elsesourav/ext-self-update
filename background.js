const VERSION = chrome.runtime.getManifest().version;
const UPDATE_MODE = "unmanaged-auto-sync-manual-reload";

async function writeLifecycle(eventName, details) {
  const lifecycle = {
    eventName,
    details,
    version: VERSION,
    updateMode: UPDATE_MODE,
    at: new Date().toISOString(),
  };

  await chrome.storage.local.set({
    lifecycle,
    currentVersion: VERSION,
  });

  console.log("[self-update-unmanaged]", lifecycle);
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
        updateMode: UPDATE_MODE,
        currentVersion: stored.currentVersion || VERSION,
        counter: stored.counter || 0,
        lifecycle: stored.lifecycle || null,
      });
    })
    .catch((error) => {
      sendResponse({
        version: VERSION,
        updateMode: UPDATE_MODE,
        currentVersion: VERSION,
        counter: 0,
        lifecycle: null,
        error: String(error),
      });
    });

  return true;
});
