# Skill: test-browser — Puppeteer Browser Testing

Write and run Puppeteer end-to-end browser tests for frontend features.

**Usage:** `/test-browser FEAT-001` or `/test-browser` (test all done features)

**Testing tool (fixed):** Puppeteer (headless Chrome)
**Install command:** `npm install --save-dev puppeteer`

---

## Step 0: Confirm Puppeteer is installed

```bash
# Check in the target frontend project directory
cat <app-path>/package.json | grep puppeteer
```

If not installed:

```bash
cd <app-path>
npm install --save-dev puppeteer
```

> **Note:** The first install downloads Chromium (~170 MB). In CI environments, prefer `puppeteer-core` + system Chrome:
> ```bash
> npm install --save-dev puppeteer-core
> ```

---

## Step 1: Read feature information

```bash
cat features/FEAT-XXX.json
```

Extract:
- `acceptance_criteria` → convert to test cases
- `app` → owning frontend project (determines test file directory)
- `type` → only `frontend` / `fullstack` features need browser testing

If the feature `type` is `backend` or `infra`, skip and note:
```
FEAT-XXX is a backend/infra feature — no browser testing needed.
Use API tests (curl / Jest / pytest) instead.
```

---

## Step 2: Determine test file location

Test files live under the frontend project's `tests/e2e/` directory:

```
<app-path>/
└── tests/
    └── e2e/
        ├── FEAT-001.test.js   ← named by feature ID
        ├── FEAT-002.test.js
        └── helpers/
            └── browser.js     ← shared browser utilities
```

If `tests/e2e/` does not exist:
```bash
mkdir -p <app-path>/tests/e2e/helpers
```

---

## Step 3: Generate shared browser helper (first time only)

If `<app-path>/tests/e2e/helpers/browser.js` does not exist, create it:

```javascript
/**
 * @module tests/e2e/helpers/browser
 * @description Shared Puppeteer browser utilities
 * @created <date>
 */

const puppeteer = require('puppeteer');

const DEFAULT_BASE_URL = process.env.TEST_BASE_URL || 'http://localhost:3000';

const DEFAULT_LAUNCH_OPTIONS = {
  headless: 'new',
  args: [
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-dev-shm-usage', // required in CI
  ],
};

/**
 * Launch a browser and open a new page.
 * @param {object} options - puppeteer.launch option overrides
 * @returns {{ browser: Browser, page: Page, baseUrl: string }}
 */
async function setupBrowser(options = {}) {
  const browser = await puppeteer.launch({
    ...DEFAULT_LAUNCH_OPTIONS,
    ...options,
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 800 });
  return { browser, page, baseUrl: DEFAULT_BASE_URL };
}

/**
 * Close the browser, swallowing errors to avoid test pollution.
 * @param {Browser} browser
 */
async function teardownBrowser(browser) {
  if (browser) {
    await browser.close().catch(() => {});
  }
}

/**
 * Click an element and wait for navigation to complete.
 * @param {Page} page
 * @param {string} triggerSelector
 */
async function clickAndNavigate(page, triggerSelector) {
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle0' }),
    page.click(triggerSelector),
  ]);
  return page.url();
}

module.exports = { setupBrowser, teardownBrowser, clickAndNavigate, DEFAULT_BASE_URL };
```

---

## Step 4: Generate the feature test file

Create `<app-path>/tests/e2e/FEAT-XXX.test.js`:

```javascript
/**
 * @feature FEAT-XXX: <feature title>
 * @type e2e browser test
 * @tool Puppeteer (headless Chrome)
 * @created <date>
 * @description <brief feature description>
 */

const { setupBrowser, teardownBrowser } = require('./helpers/browser');

describe('FEAT-XXX: <feature title>', () => {
  let browser;
  let page;
  let baseUrl;

  beforeAll(async () => {
    ({ browser, page, baseUrl } = await setupBrowser());
  });

  afterAll(async () => {
    await teardownBrowser(browser);
  });

  // ── One test per acceptance criterion ──

  test('<acceptance criteria 1 rewritten as a behavior description>', async () => {
    await page.goto(`${baseUrl}/<route>`);
    const element = await page.$('<selector>');
    expect(element).not.toBeNull();
  });

  test('<acceptance criteria 2>', async () => {
    // ...
  });

  // ── Error / edge-case scenarios ──

  test('shows an error message when invalid data is submitted', async () => {
    await page.goto(`${baseUrl}/<route>`);
    await page.type('<input selector>', '<invalid value>');
    await page.click('<submit button selector>');
    await page.waitForSelector('<error message selector>');
    const errorText = await page.$eval('<error message selector>', el => el.textContent);
    expect(errorText).toContain('<expected error text>');
  });
});
```

**Test generation rules:**
- Each `acceptance_criteria` entry → at least one `test()`
- Form features → must include at least one invalid-input error test
- Navigation features → assert the final URL
- Auth-gated features → assert redirect when unauthenticated

---

## Step 5: Add test scripts to package.json

Check whether `<app-path>/package.json` has a `test:e2e` script; add it if absent:

```json
{
  "scripts": {
    "test:e2e": "node --experimental-vm-modules node_modules/.bin/jest tests/e2e/ --testTimeout=30000",
    "test:e2e:headed": "TEST_HEADLESS=false node_modules/.bin/jest tests/e2e/ --testTimeout=30000"
  }
}
```

Confirm `jest.config.js` does not exclude `tests/e2e/` if Jest is in use.

---

## Step 6: Run tests

```bash
# Ensure the dev server is running first
# npm run dev &

cd <app-path>
npm run test:e2e -- --testPathPattern=FEAT-XXX
```

**Common options:**

```bash
# Run all e2e tests
npm run test:e2e

# Run tests for a specific feature
npm run test:e2e -- --testPathPattern=FEAT-001

# Headed mode (shows the browser window — useful for debugging)
TEST_BASE_URL=http://localhost:3000 npm run test:e2e:headed
```

---

## Step 7: Handle test failures

| Failure type | Resolution |
|---|---|
| `waiting for selector` timeout | Check the selector or increase `waitForSelector` timeout |
| `net::ERR_CONNECTION_REFUSED` | Dev server is not running — start it with `npm run dev` |
| `Cannot find module 'puppeteer'` | Re-run `npm install --save-dev puppeteer` |
| Screenshot for debugging | Add `await page.screenshot({ path: 'debug.png' })` before the failing line |
| CI sandbox error | Ensure `--no-sandbox` is in the launch args |

Test failures must be fixed. `test.skip` is not allowed.

---

## Step 8: Record test results

Append to `notes` in `features/FEAT-XXX.json`:

```
Browser tests: passed (Puppeteer) — <date>
Test file: <app-path>/tests/e2e/FEAT-XXX.test.js
```

Append to `.claude/progress/features/FEAT-XXX.log`:

```
[<ISO 8601>] TEST: browser tests passed (Puppeteer) — <N> cases all green
```

---

## Notes

- **Never install Puppeteer in production** — keep it in `devDependencies`
- **CI/CD environments** need system dependencies:
  ```bash
  # Ubuntu/Debian
  apt-get install -y libgbm-dev libasound2
  ```
- **Test isolation:** each `describe` block launches and closes its own browser to prevent state leakage
- **Timeout:** default is 30 seconds; override per test with `jest.setTimeout(60000)`
