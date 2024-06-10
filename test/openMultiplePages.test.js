const puppeteer = require('puppeteer');

// Function to generate URLs with different parameters
const generateUrls = (baseUrl, paramsArray) => {
  return paramsArray.map(params => `${baseUrl}?${new URLSearchParams(params).toString()}`);
};

describe('Open multiple pages with different URL parameters and record console.log', () => {
  let browser;

  // Launch the browser before all tests with an increased timeout
  beforeAll(async () => {
    browser = await puppeteer.launch({ headless: true });
  }, 520000); // 500 seconds timeout

  // Close the browser after all tests
  afterAll(async () => {
    if (browser) {
      await browser.close();
    }
  });

  // Helper function to open pages in batches
  const openPagesInBatches = async (urls, batchSize) => {
    const allLogs = [];
    for (let i = 0; i < urls.length; i += batchSize) {
      const batch = urls.slice(i, i + batchSize);
      const pages = await Promise.all(batch.map(url => browser.newPage()));
      
      for (const page of pages) {
        // Listen for console events
        page.on('console', msg => allLogs.push({ url: page.url(), message: msg.text() }));

        // Open the page with the generated URL
        const url = batch[pages.indexOf(page)];
        await page.goto(url);
      }

      // Close all pages in the current batch
      await Promise.all(pages.map(page => page.close()));
    }
    return allLogs;
  };

  // Test case to open multiple pages and record console logs with an increased timeout
  it('should open multiple pages and record console logs', async () => {
    const baseUrl = 'http://localhost:9292';
    const paramsArray = [];
    for (let i = 1; i <= 40; i += 1) {
      paramsArray.push({ PROLIFIC_PID: `value${i}` });
    }

    const urls = generateUrls(baseUrl, paramsArray);

    // Open pages in batches of 10
    const allLogs = await openPagesInBatches(urls, 10);

    // Log all collected console messages
    console.log('Console Logs:', allLogs);

    // You can add assertions here based on the expected console logs
    expect(allLogs.length).toBeGreaterThan(0);
  }, 520000); // 500 seconds timeout for the test case
});
