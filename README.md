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
  uses: dev-proxy-tools/actions/install@v0
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
  uses: dev-proxy-tools/actions/start@v0
  with:
    log-file: devproxy.log           # optional, defaults to devproxy.log
    config-file: ./devproxyrc.json   # optional, will use default configuration if not provided
    auto-stop: true                  # optional, defaults to false
```

**Inputs:**

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `log-file` | The file to log Dev Proxy output to | Yes | `devproxy.log` |
| `config-file` | The path to the Dev Proxy configuration file | No | Uses default configuration |
| `auto-stop` | Automatically stop Dev Proxy after the workflow completes | No | `true` |

### Stop

Stop the running Dev Proxy instance.

```yaml
- name: Stop Dev Proxy
  uses: dev-proxy-tools/actions/stop@v0
```

### Record Start

Start recording mode.

```yaml
- name: Start recording
  uses: dev-proxy-tools/actions/record-start@v0
```

### Record Stop

Stop recording mode.

```yaml
- name: Stop recording
  uses: dev-proxy-tools/actions/record-stop@v0
```

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.