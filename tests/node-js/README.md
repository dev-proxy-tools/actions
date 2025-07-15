# Dev Proxy Actions - Node.js Test

A demonstration application showing how to configure [Dev Proxy](https://aka.ms/devproxy) in GitHub Actions workflows using the [Dev Proxy Actions](https://github.com/dev-proxy-tools/actions) GitHub Action.

## Overview

This project demonstrates how to set up Dev Proxy in GitHub Actions to intercept HTTP requests and simulate API failures. When the Node.js application makes requests to external APIs, Dev Proxy will intercept them and return random errors, helping developers test error handling and resilience in their applications.

## Project Structure

```
.
├── index.mjs                 # Main test application
├── package.json             # Node.js dependencies
├── .github/
│   └── workflows/
│       └── test.yml         # GitHub Actions workflow
└── .vscode/
    └── extensions.json      # Recommended VS Code extensions
```

## Test Application

The test application (`index.mjs`) is a minimal Node.js program that:
- Uses ES modules (`.mjs` extension)
- Makes HTTP requests to `jsonplaceholder.typicode.com`
- Demonstrates how Dev Proxy intercepts requests and returns random errors
- Shows async/await patterns with IIFE for error handling testing

```javascript
import axios from 'axios';

(async () => {
  const result = await axios.get('https://jsonplaceholder.typicode.com/posts');
  const response = result.data;
  console.log(JSON.stringify(response, null, 2));
})();
```

## GitHub Actions Integration

The workflow (`.github/workflows/test.yml`) demonstrates Dev Proxy configuration by:
1. Setting up Node.js 20 environment
2. Installing dependencies with npm caching
3. **Configuring Dev Proxy using `dev-proxy-tools/actions/setup@v1`**
4. Running the test application (which will encounter intercepted requests)
5. Displaying Dev Proxy logs showing intercepted requests and random errors

### How Dev Proxy Works in the Workflow

When the Node.js application runs under Dev Proxy:
- HTTP requests to `jsonplaceholder.typicode.com` are intercepted
- Dev Proxy returns random errors instead of real API responses
- This simulates real-world API failures for testing purposes
- All interactions are logged to `devproxy.log` for analysis

### Manual Workflow Trigger

The workflow uses `workflow_dispatch` for manual testing:
```yaml
on:
  workflow_dispatch:
```

Run the workflow from the GitHub Actions tab to test Dev Proxy integration.

## Local Development

### Prerequisites
- Node.js 20 or later
- npm

### Setup and Run
```bash
# Install dependencies
npm install

# Run the test application
node index.mjs
```

### Expected Output
When run locally, the application will output JSON data from the JSONPlaceholder API. However, when run through the GitHub Actions workflow with Dev Proxy, the application will encounter random errors as Dev Proxy intercepts and simulates API failures.

## Dev Proxy Configuration Demo

When run through the GitHub Actions workflow, Dev Proxy will:
- **Intercept HTTP requests** to `jsonplaceholder.typicode.com`
- **Return random errors** instead of successful responses
- **Log all interactions** to `devproxy.log` for analysis
- **Demonstrate error simulation** for testing application resilience

This shows how Dev Proxy can be configured in CI/CD pipelines to test how applications handle API failures, network issues, and other common production scenarios.

The workflow always displays Dev Proxy logs, even on failure, for debugging purposes.

## VS Code Extensions

Recommended extensions for development:
- **Dev Proxy Toolkit** (`garrytrinder.dev-proxy-toolkit`) - Dev Proxy integration
- **GitHub Actions** (`github.vscode-github-actions`) - Workflow development
- **GitHub Local Actions** (`SanjulaGanepola.github-local-actions`) - Local testing

## Dependencies

- **axios** (`^1.6.0`) - HTTP client for making API requests
- **Node.js 20** - Runtime environment (specified in workflow)

## Testing Strategy

This demonstration showcases:
1. ✅ **Dev Proxy GitHub Action setup** - How to configure Dev Proxy in workflows
2. ✅ **HTTP request interception** - Automatic request capture and modification
3. ✅ **Random error simulation** - Testing application resilience to API failures
4. ✅ **Error logging and analysis** - Comprehensive logging of intercepted requests
5. ✅ **CI/CD integration** - Seamless integration with GitHub Actions workflows

## Contributing

When modifying the test application:
- Ensure HTTP requests can be intercepted by Dev Proxy
- Test both local execution (normal API responses) and GitHub Actions workflow (simulated errors)
- Verify Dev Proxy logs contain expected request interceptions and error details
- Maintain ES module patterns for consistency

## License

MIT
