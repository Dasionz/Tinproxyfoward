#!/bin/bash

# Function to get a new proxy from tinproxy API
get_new_proxy() {
  local api_key="YOUR_API_KEY"
  local authen_ips="YOUR_AUTHEN_IPS"
  local location="YOUR_LOCATION"

  local response=$(curl -s "https://api.tinproxy.com/proxy/get-new-proxy?api_key=$api_key&authen_ips=$authen_ips&location=$location")
  local code=$(echo "$response" | jq -r '.code')
  local message=$(echo "$response" | jq -r '.message')

  if [ "$code" -eq 1 ]; then
    echo "Failed to get new proxy: $message"
    exit 1
  fi

  local http_ipv4=$(echo "$response" | jq -r '.data.http_ipv4')
  local username=$(echo "$response" | jq -r '.data.authentication.username')
  local password=$(echo "$response" | jq -r '.data.authentication.password')

  echo "$http_ipv4:$username:$password"
}

# Function to forward the proxy to your local server
forward_proxy() {
  local proxy="$1"
  local local_server_port="6789"

  socat TCP-LISTEN:$local_server_port,fork,su=nobody TCP:$proxy &
  echo "Proxy forwarding enabled. Proxy: $proxy -> Local server: localhost:$local_server_port"
}

# Main script logic
while true; do
  proxy=$(get_new_proxy)
  forward_proxy "$proxy"
  sleep 200
done
