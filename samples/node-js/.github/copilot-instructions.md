# Dev Proxy Actions - Node.js Test Project

## Project Overview

This is a test application for the Dev Proxy Actions GitHub Action (`dev-proxy-tools/actions/setup@v1`). The project demonstrates how to integrate Dev Proxy with Node.js applications in GitHub Actions workflows.

## Architecture

- **Test Application**: Simple Node.js app (`index.mjs`) that makes HTTP requests to `jsonplaceholder.typicode.com`
- **Dev Proxy Integration**: Uses GitHub Action to intercept and log HTTP requests during testing
- **Workflow Testing**: GitHub Actions workflow validates the Dev Proxy setup and execution

## Key Components

### Application Entry Point
- `index.mjs`: ES module that uses axios to fetch JSON data from external API
- Uses async/await pattern with IIFE (Immediately Invoked Function Expression)
- Outputs formatted JSON response to console

### GitHub Actions Workflow
- Located in `.github/workflows/test.yml`
- Manually triggered (`workflow_dispatch`)
- Tests the Dev Proxy GitHub Action integration
- Always displays Dev Proxy logs (`devproxy.log`) even on failure

## Development Workflow

### Local Development
```bash
npm install
node index.mjs
```

### Testing Dev Proxy Integration
- Run workflow manually from GitHub Actions tab
- Check Dev Proxy logs in workflow output
- Verify HTTP requests are intercepted and logged

## Project-Specific Patterns

### Dependencies
- **axios**: HTTP client for making API requests
- **ES Modules**: Uses `.mjs` extension and `import` statements
- **Node.js 20**: Specified in workflow and recommended for consistency

### Workflow Structure
- Uses `cache-dependency-path: tests/node-js/package-lock.json` for npm caching
- Always runs in `tests/node-js` directory context
- Log analysis is critical - always check `devproxy.log` output

### VS Code Integration
- Recommends `garrytrinder.dev-proxy-toolkit` extension
- GitHub Actions extensions for workflow development
- Extensions support local GitHub Actions testing

## Testing Strategy

The project serves as an integration test for:
1. Dev Proxy GitHub Action setup
2. HTTP request interception
3. Log generation and analysis
4. Node.js application compatibility

When modifying the test application, ensure it makes HTTP requests that can be intercepted by Dev Proxy for validation purposes.
