document.addEventListener('DOMContentLoaded', async () => {
  // Query active tab
  if (typeof browser !== 'undefined' && browser.tabs) {
    const tabs = await browser.tabs.query({ active: true, currentWindow: true });
    if (tabs[0] && tabs[0].url) {
      try {
        const u = new URL(tabs[0].url);
        document.getElementById('domain-text').textContent = u.hostname;
      } catch (e) {}
    }
  }

  // Hook up button
  document.getElementById('btn-clean-url').addEventListener('click', async () => {
    if (typeof browser !== 'undefined' && browser.tabs) {
      const tabs = await browser.tabs.query({ active: true, currentWindow: true });
      if (tabs[0] && tabs[0].url) {
        const TRACKING_PARAMS = [
          'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content', 'utm_id',
          'fbclid', 'gclid', 'gbraid', 'wbraid', 'msclkid', 'igshid', 'si', '_ga', '_gl'
        ];
        try {
          const u = new URL(tabs[0].url);
          TRACKING_PARAMS.forEach(p => u.searchParams.delete(p));
          await browser.tabs.update(tabs[0].id, { url: u.toString() });
          window.close();
        } catch (e) {}
      }
    }
  });
});
