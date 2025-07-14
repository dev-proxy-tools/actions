# Dev Proxy GitHub Actions

A collection of GitHub Actions for using [Dev Proxy](https://aka.ms/devproxy) in your GitHub Action workflows.

## Actions

- [`install`](#install) - Install Dev Proxy
- [`start`](#start) - Start Dev Proxy
- [`stop`](#stop) - Stop Dev Proxy instance
- [`record-start`](#record-start) - Start recording mode
- [`record-stop`](#record-stop) - Stop recording mode
- [`chromium-cert`](#chromium-cert) - Install the Dev Proxy certificate for Chromium browsers

## Usage

> [!IMPORTANT]  
> Dev Proxy Actions support Linux based runners only.

### Install

Install Dev Proxy in your workflow. You can specify a version, or use the latest.

```yaml
- name: Install Dev Proxy
  uses: dev-proxy-tools/actions/install@v1
  with:
    version: v0.29.2 # optional, defaults to latest
```

**Inputs:**

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `version` | Version of Dev Proxy to install (e.g., v0.29.2, v1.0.0-beta.2) | No | latest |

### Start

Start Dev Proxy with optional configuration file. Dev Proxy will run in the background and log its output to a log file.

```yaml
- name: Start Dev Proxy
  id: start-devproxy
  uses: dev-proxy-tools/actions/start@v1
  with:
    log-file: devproxy.log           # optional, defaults to devproxy.log
    config-file: ./devproxyrc.json   # optional, will use default configuration if not provided
    auto-stop: true                  # optional, defaults to true

- name: Use Dev Proxy URLs
  run: |
    echo "Proxy URL: ${{ steps.start-devproxy.outputs.proxy-url }}"
    echo "API URL: ${{ steps.start-devproxy.outputs.api-url }}"
    # Use the proxy URL for requests
    curl -x "${{ steps.start-devproxy.outputs.proxy-url }}" https://example.com
```

This action automatically:
 
 - Installs and trusts Dev Proxy certificate on the runner.
 - Sets the `http_proxy` and `https_proxy` environment variables to `http://127.0.0.1:8000`, allowing subsequent steps to route HTTP and HTTPS traffic through Dev Proxy.
 - Registers a post-step that will stop Dev Proxy and clean up the environment variables when the workflow completes, unless `auto-stop` is set to `false`.
 - Provides the proxy and API URLs as action outputs for use in subsequent steps.

**Inputs:**

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `log-file` | The file to log Dev Proxy output to | Yes | `devproxy.log` |
| `config-file` | The path to the Dev Proxy configuration file | No | Uses default configuration |
| `auto-stop` | Automatically stop Dev Proxy after the workflow completes | No | `true` |

**Outputs:**

| Name | Description |
|------|-------------|
| `proxy-url` | The URL of the running Dev Proxy instance (`http://127.0.0.1:8000`) |
| `api-url` | The URL of the Dev Proxy API (`http://127.0.0.1:8897/proxy`) |

### Stop

Stop the running Dev Proxy instance.

```yaml
- name: Stop Dev Proxy
  uses: dev-proxy-tools/actions/stop@v1
```

This action resets the `http_proxy` and `https_proxy` environment variables to empty strings, effectively disabling the Dev Proxy for subsequent steps.

### Record Start

Start recording mode.

```yaml
- name: Start recording
  uses: dev-proxy-tools/actions/record-start@v1
```

### Record Stop

Stop recording mode.

```yaml
- name: Stop recording
  uses: dev-proxy-tools/actions/record-stop@v1
```

### Chromium Certificate

Install the Dev Proxy certificate for Chromium browsers in GitHub Actions workflows.

```yaml
- name: Install the Dev Proxy certificate for Chromium
  uses: dev-proxy-tools/actions/chromium-cert@v1
```

## Example Workflow

The following example demonstrates how to use the Dev Proxy actions in a GitHub Actions workflow.

```yaml
name: Example Dev Proxy workflow

on:
  workflow_dispatch:

jobs:
  example-dev-proxy:
    name: Example Dev Proxy Job
    runs-on: ubuntu-latest
    steps:
      - name: Intall Dev Proxy
        id: install-latest
        uses: dev-proxy-tools/actions/install@v1

      - name: Start Dev Proxy
        id: start-devproxy
        uses: dev-proxy-tools/actions/start@v1

      - name: Start recording
        id: start-recording
        uses: dev-proxy-tools/actions/record-start@v1

      - name: Send request using proxy URL output
        id: send-request
        run: |
          echo "Using proxy URL: ${{ steps.start-devproxy.outputs.proxy-url }}"
          curl -ikx "${{ steps.start-devproxy.outputs.proxy-url }}" https://jsonplaceholder.typicode.com/posts

      - name: Stop recording
        id: stop-recording
        uses: dev-proxy-tools/actions/record-stop@v1

      - name: Show logs
        run: |
          echo "Dev Proxy logs:"
          cat devproxy.log
```

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.