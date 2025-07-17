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
 - Caches the Dev Proxy installation to improve performance on subsequent workflow runs.

**Inputs:**

You can customize the behavior of the `setup` action using the following inputs:

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `auto-start` | Automatically start Dev Proxy | No | `true` |
| `auto-stop` | Automatically stop Dev Proxy after the workflow completes | No | `true` |
| `auto-record` | Automatically start Dev Proxy in recording mode | No | `false` |
| `config-file` | Path to the Dev Proxy configuration file | No | Uses default configuration |
| `enable-cache` | Enable caching of Dev Proxy installation to speed up subsequent runs | No | `true` |
| `log-file` | Path to log Dev Proxy output to | No | `devproxy.log` |
| `report-job-summary` | Path to output report content for use as summaries (e.g., `$GITHUB_STEP_SUMMARY`). | No | None |
| `version` | Version of Dev Proxy to install (e.g., v0.29.2, v1.0.0-beta.2) | No | latest |

**Outputs:**

The `setup` action provides the following outputs that can be used in subsequent steps:

| Name | Description |
|------|-------------|
| `api-url` | The URL of the Dev Proxy API |
| `proxy-url` | The URL of the running Dev Proxy instance |

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
| `api-url` | The URL of the Dev Proxy API |
| `proxy-url` | The URL of the running Dev Proxy instance |

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
      # Caching is enabled by default to speed up subsequent runs
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