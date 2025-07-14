#!/bin/bash
set -e

# stop-devproxy.sh - Script to stop Dev Proxy
# Usage: ./stop-devproxy.sh [auto_stop]

auto_stop="${1:-true}"

if [ "$auto_stop" = "true" ]; then
  echo "Stopping Dev Proxy..."
  curl -X POST http://127.0.0.1:8897/proxy/stopproxy || echo "Stop command may have failed, but continuing cleanup"
  echo "http_proxy=" >> $GITHUB_ENV
  echo "https_proxy=" >> $GITHUB_ENV
  echo "Dev Proxy has been stopped."
fi
