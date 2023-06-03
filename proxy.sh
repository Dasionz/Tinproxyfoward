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

# Main script logic
while true; do
  proxy=$(get_new_proxy)
  
  # Update Tinyproxy configuration
  sed -i "/upstream http/c\upstream http \"http://$proxy\"" /etc/tinyproxy/tinyproxy.conf
  
  # Restart Tinyproxy
  sudo service tinyproxy restart
  
  sleep 200
done
