#!/bin/bash

read -p "Enter your API Key: " api_key

# Function to get a new proxy from tinproxy API
get_new_proxy() {
  local response=$(curl -s "https://api.tinproxy.com/proxy/get-new-proxy?api_key=$api_key")

  local http_ipv4=$(echo "$response" | jq -r '.data.http_ipv4')
  local username=$(echo "$response" | jq -r '.data.authentication.username')
  local password=$(echo "$response" | jq -r '.data.authentication.password')

  echo "$http_ipv4:$username:$password"
}

# Function to forward the proxy to your local server using mitmproxy
forward_proxy() {
  local proxy="$1"
  local local_server_port="6789"

  mitmproxy --mode reverse:http://localhost:$local_server_port --listen-host 0.0.0.0 --listen-port $local_server_port --set http_proxy=http://$proxy --set https_proxy=http://$proxy --set block_global=false
}

# Main script logic
while true; do
  proxy=$(get_new_proxy)
  forward_proxy "$proxy"
  sleep 200
done
