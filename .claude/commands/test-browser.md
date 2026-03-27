# 技能：test-browser — Puppeteer 浏览器测试

为前端功能编写并运行 Puppeteer 端对端浏览器测试。

**用法：** `/test-browser FEAT-001` 或 `/test-browser`（测试所有 done 功能）

**测试工具（固定）：** Puppeteer（headless Chrome）  
**安装命令：** `npm install --save-dev puppeteer`

---

## Step 0：确认 Puppeteer 已安装

```bash
# 在目标前端项目目录下检查
cat <app-path>/package.json | grep puppeteer
```

若未安装：

```bash
cd <app-path>
npm install --save-dev puppeteer
```

> **注意：** Puppeteer 首次安装会下载 Chromium（~170MB），在 CI 环境中建议使用 `puppeteer-core` + 系统 Chrome：
> ```bash
> npm install --save-dev puppeteer-core
> ```

---

## Step 1：读取功能信息

```bash
cat features/FEAT-XXX.json
```

提取：
- `acceptance_criteria`（验收标准 → 转为测试用例）
- `app`（所属前端项目，确定测试文件目录）
- `type`（仅 `frontend` / `fullstack` 类型需要浏览器测试）

若功能 `type` 为 `backend` 或 `infra`，跳过并提示：
```
FEAT-XXX 为后端/基础设施功能，无需浏览器测试。
建议改用 API 测试（curl / Jest / pytest）。
```

---

## Step 2：确定测试文件位置

测试文件放在前端项目的 `tests/e2e/` 目录下：

```
<app-path>/
└── tests/
    └── e2e/
        ├── FEAT-001.test.js   ← 按功能 ID 命名
        ├── FEAT-002.test.js
        └── helpers/
            └── browser.js     ← 公共浏览器工具函数
```

若 `tests/e2e/` 不存在：
```bash
mkdir -p <app-path>/tests/e2e/helpers
```

---

## Step 3：生成公共 browser helper（首次创建时）

若 `<app-path>/tests/e2e/helpers/browser.js` 不存在，创建：

```javascript
/**
 * @module tests/e2e/helpers/browser
 * @description Puppeteer 公共浏览器工具函数
 * @created <日期>
 */

const puppeteer = require('puppeteer');

const DEFAULT_BASE_URL = process.env.TEST_BASE_URL || 'http://localhost:3000';

const DEFAULT_LAUNCH_OPTIONS = {
  headless: 'new',
  args: [
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-dev-shm-usage', // CI 环境必须
  ],
};

/**
 * 启动浏览器并打开新页面
 * @param {object} options - puppeteer.launch 选项覆盖
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
 * 关闭浏览器，捕获错误防止测试污染
 * @param {Browser} browser
 */
async function teardownBrowser(browser) {
  if (browser) {
    await browser.close().catch(() => {});
  }
}

/**
 * 等待页面跳转并返回最终 URL
 * @param {Page} page
 * @param {string} triggerSelector - 触发跳转的元素选择器
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

## Step 4：生成功能测试文件

为目标功能创建 `<app-path>/tests/e2e/FEAT-XXX.test.js`。

**测试文件模板：**

```javascript
/**
 * @feature FEAT-XXX: <功能标题>
 * @type e2e browser test
 * @tool Puppeteer (headless Chrome)
 * @created <日期>
 * @description <功能描述简要>
 */

const { setupBrowser, teardownBrowser } = require('./helpers/browser');

describe('FEAT-XXX: <功能标题>', () => {
  let browser;
  let page;
  let baseUrl;

  beforeAll(async () => {
    ({ browser, page, baseUrl } = await setupBrowser());
  });

  afterAll(async () => {
    await teardownBrowser(browser);
  });

  // ── 从 acceptance_criteria 生成每条测试用例 ──

  test('<验收标准 1 改写为行为描述>', async () => {
    await page.goto(`${baseUrl}/<路由>`);
    // <具体断言>
    const element = await page.$('<选择器>');
    expect(element).not.toBeNull();
  });

  test('<验收标准 2>', async () => {
    // ...
  });

  // ── 错误场景 ──

  test('输入非法数据时显示错误提示', async () => {
    await page.goto(`${baseUrl}/<路由>`);
    await page.type('<输入框选择器>', '<非法值>');
    await page.click('<提交按钮选择器>');
    await page.waitForSelector('<错误提示选择器>');
    const errorText = await page.$eval('<错误提示选择器>', el => el.textContent);
    expect(errorText).toContain('<预期错误文字>');
  });
});
```

**测试用例生成规则：**
- 每条 `acceptance_criteria` → 至少一个 `test()`
- 表单功能 → 必须包含一个"非法输入"错误测试
- 导航/跳转功能 → 验证最终 URL
- 权限功能 → 验证未登录时重定向

---

## Step 5：更新 package.json test 脚本

检查 `<app-path>/package.json` 中是否有 `test:e2e` 脚本，若无则添加：

```json
{
  "scripts": {
    "test:e2e": "node --experimental-vm-modules node_modules/.bin/jest tests/e2e/ --testTimeout=30000",
    "test:e2e:headed": "TEST_HEADLESS=false node_modules/.bin/jest tests/e2e/ --testTimeout=30000"
  }
}
```

若项目使用 Jest，确认 `jest.config.js` 中包含 e2e 目录（或不排除它）。

---

## Step 6：运行测试

```bash
# 确保开发服务器已启动
# npm run dev &  ← 若尚未启动

cd <app-path>
npm run test:e2e -- --testPathPattern=FEAT-XXX
```

**常见运行参数：**

```bash
# 运行全部 e2e 测试
npm run test:e2e

# 只运行指定功能测试
npm run test:e2e -- --testPathPattern=FEAT-001

# 有头模式（调试用，可看到浏览器窗口）
TEST_BASE_URL=http://localhost:3000 npm run test:e2e:headed
```

---

## Step 7：处理测试失败

| 失败类型 | 处理方式 |
|---------|---------|
| `waiting for selector timeout` | 检查选择器是否正确，或增加 `waitForSelector` 超时时间 |
| `net::ERR_CONNECTION_REFUSED` | 开发服务器未启动，先运行 `npm run dev` |
| `Cannot find module 'puppeteer'` | 重新运行 `npm install --save-dev puppeteer` |
| 截图辅助调试 | 在失败行前加 `await page.screenshot({ path: 'debug.png' })` |
| CI 环境沙盒错误 | 确认 launch options 中包含 `--no-sandbox` |

测试失败必须修复，不允许跳过（`test.skip`）。

---

## Step 8：记录测试结果

更新 `features/FEAT-XXX.json`，在 `notes` 字段追加：

```
浏览器测试：已通过（Puppeteer）— <日期>
测试文件：<app-path>/tests/e2e/FEAT-XXX.test.js
```

在 `.claude/progress/features/FEAT-XXX.log` 中追加：

```
[<ISO 8601>] TEST: 浏览器测试通过 (Puppeteer) — <N> 个用例全部通过
```

---

## 注意事项

- **不要在生产环境安装 Puppeteer**；确保它在 `devDependencies` 中
- **CI/CD 环境** 需要安装系统依赖：
  ```bash
  # Ubuntu/Debian
  apt-get install -y libgbm-dev libasound2
  ```
- **测试隔离**：每个 `describe` 块独立启动/关闭浏览器，防止状态污染
- **超时设置**：默认 30 秒，复杂交互可在单个 test 中覆盖：`jest.setTimeout(60000)`
