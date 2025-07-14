#!/bin/bash
set -e

# start-devproxy.sh - Script to start Dev Proxy
# Usage: ./start-devproxy.sh [log_file] [config_file]

log_file="${1:-devproxy.log}"
config_file="$2"

echo "Starting Dev Proxy..."

# Create directory for Dev Proxy configuration and certificates
root_cert_dir="$HOME/.config/dev-proxy"
mkdir -p "$root_cert_dir"

# Set certificate path
cert_path="$root_cert_dir/rootCert.pfx"

echo "Using certificate path: $cert_path"

# Set environment variables for Dev Proxy
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
         
# Set config arguments if provided
config_arg=""
if [ -n "$config_file" ]; then
  config_arg="-c $config_file"
fi

# Use appropriate executable based on whether beta version was installed
devproxy_exec="./devproxy/devproxy"
if [ "$DEVPROXY_BETA" = "true" ]; then
  devproxy_exec="./devproxy-beta/devproxy-beta"
fi

# start Dev Proxy in the background
# log Dev Proxy output to the log file
# log stdout and stderr to the file
$devproxy_exec $config_arg > $log_file 2>&1 &

# wait for init
echo "Waiting for Dev Proxy to start..."
while true; do
  if grep -q "Configure your operating system to use this proxy's port and address 127.0.0.1:8000" $log_file; then
    break
  fi
  sleep 1
done

echo "Dev Proxy is running!"

# Set action outputs
echo "proxy-url=http://127.0.0.1:8000" >> $GITHUB_OUTPUT
echo "api-url=http://127.0.0.1:8897/proxy" >> $GITHUB_OUTPUT

echo "🔒 Trusting Dev Proxy certificate..."

echo "Checking for certificate at: $cert_path"
if [ -f "$cert_path" ]; then
  echo "✅ Certificate found"
  
  echo "Exporting the Dev Proxy's Root Certificate"
  if openssl pkcs12 -in "$cert_path" -clcerts -nokeys -out dev-proxy-ca.crt -passin pass:""; then
    echo "Installing the Dev Proxy's Root Certificate"
    sudo cp dev-proxy-ca.crt /usr/local/share/ca-certificates/

    echo "Updating the CA certificates"
    sudo update-ca-certificates
    
    # Set the system proxy settings
    echo "http_proxy=http://127.0.0.1:8000" >> $GITHUB_ENV
    echo "https_proxy=http://127.0.0.1:8000" >> $GITHUB_ENV
          
    echo "✅ Dev Proxy certificate trusted successfully!"
  else
    echo "❌ Failed to export certificate from $cert_path"
    echo "⚠️ SSL verification may fail"
  fi
else
  echo "❌ Certificate not found at: $cert_path"
  echo "⚠️ Skipping certificate trust - SSL verification may fail"
fi
