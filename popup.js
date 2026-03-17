const versionEl = document.getElementById("version");
const counterEl = document.getElementById("counter");
const lifecycleEl = document.getElementById("lifecycle");
const eventTimeEl = document.getElementById("event-time");

function formatTime(isoDate) {
  if (!isoDate) {
    return "-";
  }

  const dt = new Date(isoDate);
  if (Number.isNaN(dt.getTime())) {
    return "-";
  }

  return dt.toLocaleString();
}

async function getStatus() {
  try {
    return await chrome.runtime.sendMessage({ type: "get-status" });
  } catch (error) {
    return {
      version: "unknown",
      counter: 0,
      lifecycle: null,
      error: String(error),
    };
  }
}

async function refreshStatus() {
  const status = await getStatus();

  versionEl.textContent = status.version || "unknown";
  counterEl.textContent = String(status.counter || 0);
  lifecycleEl.textContent = status.lifecycle?.eventName || "-";
  eventTimeEl.textContent = formatTime(status.lifecycle?.at);
}

async function incrementCounter() {
  const stored = await chrome.storage.local.get(["counter"]);
  const nextCounter = (stored.counter || 0) + 1;
  await chrome.storage.local.set({ counter: nextCounter });
  await refreshStatus();
}

async function resetCounter() {
  await chrome.storage.local.set({ counter: 0 });
  await refreshStatus();
}

document.getElementById("increment").addEventListener("click", () => {
  void incrementCounter();
});

document.getElementById("reset").addEventListener("click", () => {
  void resetCounter();
});

document.getElementById("refresh").addEventListener("click", () => {
  void refreshStatus();
});

void refreshStatus();
