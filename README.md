# Dev Proxy GitHub Actions

A collection of GitHub Actions for using [Dev Proxy](https://aka.ms/devproxy) in your GitHub Action workflows.

## Actions

- [`setup`](#setup) - Setup Dev Proxy
- [`start`](#start) - Start Dev Proxy manually
- [`stop`](#stop) - Stop Dev Proxy instance
- [`record-start`](#record-start) - Start recording
- [`record-stop`](#record-stop) - Stop recording
- [`chromium-cert`](#chromium-cert) - Install Dev Proxy certificate for Chromium browsers

## Usage

> [!IMPORTANT]  
> Dev Proxy Actions support Linux based runners only.

### Setup

Use the `setup` action to install and start Dev Proxy.

```yaml
- name: Setup Dev Proxy
  id: setup-devproxy
  uses: dev-proxy-tools/actions/setup@v1
```

The `setup` action automatically:
 
 - Installs the latest version of Dev Proxy.
 - Start Dev Proxy using the default configuration file, `devroxyrc.json`.
 - Install and trust Dev Proxy certificate on the runner.
 - Set `http_proxy` and `https_proxy` environment variables to route traffic through Dev Proxy.
 - Registers a post-step that will stop Dev Proxy and clean up when the workflow completes.

**Inputs:**

You can customize the behavior of the `setup` action using the following inputs:

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `auto-start` | Automatically start Dev Proxy | No | `true` |
| `auto-stop` | Automatically stop Dev Proxy after the workflow completes | No | `true` |
| `auto-record` | Automatically start Dev Proxy in recording mode | No | `false` |
| `config-file` | Path to the Dev Proxy configuration file | No | Uses default configuration |
| `log-file` | Path to log Dev Proxy output to | No | `devproxy.log` |
| `report-job-summary` | Path to output report content for use as summaries (e.g., `$GITHUB_STEP_SUMMARY`). | No | None |
| `version` | Version of Dev Proxy to install (e.g., v0.29.2, v1.0.0-beta.2) | No | latest |

**Outputs:**

The `setup` action provides the following outputs that can be used in subsequent steps:

| Name | Description |
|------|-------------|
| `api-url` | URL of the Dev Proxy API (e.g. `http://127.0.0.1:8897/proxy`) - only set when start is true |
| `proxy-url` | URL of the running Dev Proxy instance (e.g. `http://127.0.0.1:8000`) - only set when start is true |

### Start

Use the `start` action to start Dev Proxy manually.

```yaml
# Install Dev Proxy
- name: Setup Dev Proxy
  id: setup-devproxy
  uses: dev-proxy-tools/actions/setup@v1
  with:
    auto-start: false

# Additional steps can be added here

- name: Start Dev Proxy
  id: start-devproxy
  uses: dev-proxy-tools/actions/start@v1
```

The `start` action automatically:
 
 - Start Dev Proxy using the default configuration file, `devroxyrc.json`.
 - Install and trust Dev Proxy certificate on the runner.
 - Set `http_proxy` and `https_proxy` environment variables to route traffic through Dev Proxy.
 - Registers a post-step that will stop Dev Proxy and clean up when the workflow completes.

**Inputs:**

You can customize the behavior of the `start` action using the following inputs:

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `auto-stop` | Automatically stop Dev Proxy after the workflow completes | No | `true` |
| `auto-record` | Automatically start Dev Proxy in recording mode | No | `false` |
| `config-file` | Path to the Dev Proxy configuration file | No | Uses default configuration |
| `log-file` | Path to log Dev Proxy output to | No | `devproxy.log` |
| `report-job-summary` | Path to output report content for use as summaries (e.g., `$GITHUB_STEP_SUMMARY`). | No | None |

**Outputs:**

The `start` action provides the following outputs that can be used in subsequent steps:

| Name | Description |
|------|-------------|
| `api-url` | The URL of the Dev Proxy API (`http://127.0.0.1:8897/proxy`) |
| `proxy-url` | The URL of the running Dev Proxy instance (`http://127.0.0.1:8000`) |

### Stop

Use the `stop` action to stop the running Dev Proxy instance and clean up the environment variables. This is useful if you want to stop Dev Proxy manually, for example, to generate reports that you want to upload as artifacts.

```yaml
# Install and start Dev Proxy in recording mode
- name: Setup Dev Proxy
  id: setup-devproxy
  uses: dev-proxy-tools/actions/setup@v1
  with:
    auto-record: true

# Additional steps can be added here

- name: Stop Dev Proxy
  uses: dev-proxy-tools/actions/stop@v1

# Upload generated reports as artifacts
- name: Upload Dev Proxy reports
  uses: actions/upload-artifact@v4
  with:
    name: Reports
    path: ./*Reporter*
```

### Start recording

Use the `record-start` action to start recording mode manually.

```yaml
# Install and start Dev Proxy
- name: Setup Dev Proxy
  id: setup-devproxy
  uses: dev-proxy-tools/actions/setup@v1

# Additional steps can be added here

- name: Start recording
  uses: dev-proxy-tools/actions/record-start@v1
```

### Stop recording

Use the `record-stop` action to stop recording mode.

```yaml
# Install and start Dev Proxy
- name: Setup Dev Proxy
  id: setup-devproxy
  uses: dev-proxy-tools/actions/setup@v1

# Additional steps can be added here

- name: Start recording
  uses: dev-proxy-tools/actions/record-start@v1

# Additional steps can be added here

- name: Stop recording
  uses: dev-proxy-tools/actions/record-stop@v1
```

### Install Dev Proxy certificate for Chromium browsers

Use the `chromium-cert` action to install the Dev Proxy certificate for Chromium browsers. This is useful for ensuring that requests made through Dev Proxy are trusted by Chromium-based browsers. Typically you would use this action in a workflow that uses Playwright, or other end to end testing framework, that require a trusted certificate for running tests inside a browser.

```yaml
# Install and start Dev Proxy
- name: Setup Dev Proxy
  id: setup-devproxy
  uses: dev-proxy-tools/actions/setup@v1

# Install and trust the Dev Proxy certificate for Chromium
- name: Install the Dev Proxy certificate for Chromium
  uses: dev-proxy-tools/actions/chromium-cert@v1

# Run test suites
- name: Run tests
  run: npm test
```

## Example Workflow

A simple example workflow that uses the `setup` action to install and start Dev Proxy, sends a request through it, and shows the logs:

```yaml
name: Example Dev Proxy workflow

on:
  workflow_dispatch:

jobs:
  example-dev-proxy:
    name: Example Dev Proxy Job
    runs-on: ubuntu-latest
    steps:

      # Install v0.29.2 and start Dev Proxy in recording mode
      # Reports are written to Job Summary
      - name: Setup Dev Proxy
        id: setup-devproxy
        uses: dev-proxy-tools/actions/setup@v1
        with:
          version: v0.29.2
          auto-record: true
          report-job-summary: $GITHUB_STEP_SUMMARY

      # Send a request through Dev Proxy
      - name: Send request
        run: |
          curl -ikx "${{ steps.setup-devproxy.outputs.proxy-url }}" https://jsonplaceholder.typicode.com/posts

      # Show the logs on success or failure
      - name: Show logs
        if: always()
        run: |
          echo "Dev Proxy logs:"
          cat devproxy.log
```

## GitHub Copilot Agent Integration

The following prompt is designed for GitHub Copilot agents to assist with updating workflows to use Dev Proxy actions. Copy this prompt when asking Copilot to help integrate Dev Proxy into your repository workflows.

### Copilot Agent Prompt

```
Help me update my GitHub Actions workflows to use Dev Proxy actions for intercepting and analyzing HTTP/HTTPS requests. 

Please:
1. Analyze existing workflow files in .github/workflows/ directory
2. Identify workflows that make HTTP/HTTPS requests (look for steps using curl, npm, pip, API calls, or web testing)
3. Update workflows to use Dev Proxy actions from dev-proxy-tools/actions

For each workflow that could benefit from Dev Proxy:
- Add Dev Proxy setup step early in the job: `uses: dev-proxy-tools/actions/setup@v1`
- Enable recording mode with `auto-record: true` if the workflow tests or monitors API usage
- Use the proxy URL output `${{ steps.setup-devproxy.outputs.proxy-url }}` in curl commands with `-x` flag
- Add Dev Proxy certificate installation for browser-based testing: `uses: dev-proxy-tools/actions/chromium-cert@v1`
- Include log output step to show Dev Proxy activity: `cat devproxy.log`

Key integration patterns:
- For API testing: Use setup action with auto-record: true
- For web testing with Playwright/Selenium: Add chromium-cert action after setup
- For CI/CD pipelines: Use setup action to monitor dependency downloads and API calls
- For manual control: Use individual start/stop actions instead of setup

Example transformation:
BEFORE:
```yaml
- name: Test API
  run: curl https://api.example.com/data
```

AFTER:
```yaml
- name: Setup Dev Proxy
  id: setup-devproxy
  uses: dev-proxy-tools/actions/setup@v1
  with:
    auto-record: true

- name: Test API
  run: curl -x "${{ steps.setup-devproxy.outputs.proxy-url }}" https://api.example.com/data

- name: Show Dev Proxy logs
  if: always()
  run: cat devproxy.log
```

Apply these changes to relevant workflows in my repository.
```

## Samples

You can find more examples and samples in the [tests](./tests/) directory.

| Test Project | Description |
|--------------|-------------|
| [llm-usage](./tests/llm-usage/) | Tests AI/LLM usage tracking and reporting with OpenAI telemetry plugin, includes Playwright tests for feedback analysis |
| [node-js](./tests/node-js/) | Simple Node.js integration test that validates basic Dev Proxy functionality with HTTP requests |
| [playwright-web-app](./tests/playwright-web-app/) | Playwright end-to-end testing example with mock data configuration and blog post testing scenarios |

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.