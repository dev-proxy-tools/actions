# Copilot Instructions for Playwright Web App

## Project Architecture

This is a **Dev Proxy integration demo** project that showcases API mocking and network simulation for end-to-end testing. The architecture consists of:

- **Static web app** (`public/index.html`) - Single-page blog app that fetches from `https://api.blog.com/posts`
- **Dev Proxy layer** (`.devproxy/`) - Intercepts API calls and returns mock responses
- **Playwright tests** (`tests/`) - E2E tests that run against the mocked API
- **GitHub Actions workflow** - CI pipeline demonstrating Dev Proxy integration

## Key Dependencies & Setup

**Dev Proxy is REQUIRED** for local development and testing. The app will fail without it running.

### Local Development Workflow
```bash
# 1. Install Dev Proxy (external dependency)
# 2. Start Dev Proxy first
devproxy
# 3. Start the web app
npm start
# 4. Run tests
npm test
```

### Test Configuration Pattern
- **Base URL**: `http://localhost:3000` (configured in `playwright.config.js`)
- **Browser**: Microsoft Edge only (project uses `msedge` channel)
- **Web Server**: Playwright auto-starts via `webServer` config
- **Test Timeout**: 10 seconds for post loading (see `blog-posts.spec.js`)

## Dev Proxy Configuration

The `.devproxy/` folder contains the core mocking setup:

- **`devproxyrc.json`**: Configures MockResponsePlugin + LatencyPlugin, watches `https://api.blog.com/*`
- **`mocks.json`**: Contains 5 hardcoded blog posts with specific titles/authors/dates

**Critical**: Tests expect exactly 5 posts with specific titles. When modifying mocks, update test expectations in `blog-posts.spec.js`.

## Testing Patterns

### API Mocking Approach
- Tests run against mocked API responses (not real APIs)
- Loading states are tested by intercepting network timing
- Mock data structure: `{ posts: [ { id, title, excerpt, date, author, readTime } ] }`

### Test Structure
```javascript
// Pattern: Wait for specific count, then verify content
await expect(page.locator('#posts article')).toHaveCount(5, { timeout: 10000 });
await expect(page.locator('#posts')).toContainText('Expected Title');
```

## CI/CD Integration

The GitHub Actions workflow demonstrates:
- Dev Proxy certificate installation for Chromium browsers
- Sequential setup: Node.js → dependencies → Edge → Dev Proxy → certificate → tests
- Dev Proxy logs output for debugging (`devproxy.log`)

## File Naming & Structure Conventions

- Tests: `*.spec.js` in `tests/` directory
- Config: `playwright.config.js` (not `.ts`)
- Static assets: `public/` directory served by `http-server`
- Dev Proxy configs: `.devproxy/` directory (not `devproxy/`)

## Common Tasks

- **Add new mock endpoint**: Modify `.devproxy/mocks.json` and restart Dev Proxy
- **Debug test failures**: Check `devproxy.log` and use `npm run test:debug`
- **Run headed tests**: `npm run test:headed` or `npm run test:ui`
- **Local workflow testing**: Use GitHub Local Actions extension with `linux/amd64` architecture
