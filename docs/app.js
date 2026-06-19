// Weizen Paymaster Demo — UI logic only.
// NOTE: This is a UI simulation/mock. No live chain calls, no real UserOperation.
"use strict";

(function () {
  var steps = document.querySelectorAll(".step");
  var simBtn = document.getElementById("simBtn");
  var result = document.getElementById("result");

  function clearActive() {
    steps.forEach(function (s) { s.classList.remove("active"); });
  }

  // Animate through each flow box in sequence, then show the mock result.
  function simulate() {
    simBtn.disabled = true;
    result.hidden = true;
    clearActive();

    var i = 0;
    var stepDelay = 520;

    function next() {
      if (i > 0) steps[i - 1].classList.remove("active");
      if (i < steps.length) {
        steps[i].classList.add("active");
        i++;
        setTimeout(next, stepDelay);
      } else {
        // finished — keep last box lit briefly, then settle
        setTimeout(function () {
          clearActive();
          showResult();
          simBtn.disabled = false;
        }, stepDelay);
      }
    }
    next();
  }

  function showResult() {
    result.innerHTML =
      "✅ UserOp included — user paid 0 ETH (sponsored by Paymaster)" +
      "<small>🧪 Mock result — UI simulation only, not a live on-chain transaction. " +
      "ค่าทั้งหมดเป็นตัวอย่างจำลอง ไม่ใช่ข้อมูลจริงจากเชน 20260619</small>";
    result.hidden = false;
  }

  if (simBtn) simBtn.addEventListener("click", simulate);

  // Tabs: VerifyingPaymaster <-> TokenPaymaster
  var tabs = document.querySelectorAll(".tab");
  tabs.forEach(function (tab) {
    tab.addEventListener("click", function () {
      tabs.forEach(function (t) { t.classList.remove("active"); });
      tab.classList.add("active");

      var target = tab.getAttribute("data-tab");
      document.querySelectorAll(".tab-panel").forEach(function (panel) {
        var match = panel.id === "tab-" + target;
        panel.classList.toggle("active", match);
        panel.hidden = !match;
      });
    });
  });
})();
