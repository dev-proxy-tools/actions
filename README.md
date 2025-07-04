# Dev Proxy GitHub Actions

A collection of GitHub Actions for using [Dev Proxy](https://aka.ms/devproxy) in your GitHub Action workflows.

## Actions

- [`install`](#install) - Install Dev Proxy
- [`start`](#start) - Start Dev Proxy
- [`stop`](#stop) - Stop Dev Proxy instance
- [`record-start`](#record-start) - Start recording mode
- [`record-stop`](#record-stop) - Stop recording mode

## Usage

### Install

Install Dev Proxy in your workflow. You can specify a version or use the latest.

```yaml
- name: Install Dev Proxy
  uses: dev-proxy-tools/actions/install@main
  with:
    version: v0.29.2
```

**Inputs:**

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `version` | Version of Dev Proxy to install (e.g., v0.29.2) | No | latest |

### Start

Start Dev Proxy with optional configuration file. Dev Proxy will run in the background and log its output to a specified file.

```yaml
- name: Start Dev Proxy
  uses: dev-proxy-tools/actions/start@main
  with:
    logFile: devproxy.log           # optional, defaults to devproxy.log
    configFile: ./devproxy.json     # optional, defaults to devproxyrc.json
```

**Inputs:**

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `logFile` | The file to log Dev Proxy output to | Yes | `devproxy.log` |
| `configFile` | The path to the Dev Proxy configuration file | No | - |

### Stop

Stop the running Dev Proxy instance.

```yaml
- name: Stop Dev Proxy
  uses: dev-proxy-tools/actions/stop@main
```

### Record Start

Start recording mode.

```yaml
- name: Start recording
  uses: dev-proxy-tools/actions/record-start@main
```

### Record Stop

Stop recording mode.

```yaml
- name: Stop recording
  uses: dev-proxy-tools/actions/record-stop@main
```

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.