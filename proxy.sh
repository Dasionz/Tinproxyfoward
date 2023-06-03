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

# Function to update the proxychains config file with the new proxy
update_proxychains_config() {
  local proxy="$1"
  local proxychains_config="/etc/proxychains.conf"

  # Backup original config
  cp $proxychains_config $proxychains_config.backup

  # Extract the proxy address and the username:password
  local proxy_address=$(echo $proxy | cut -d ':' -f 1)
  local proxy_auth=$(echo $proxy | cut -d ':' -f 2-3)

  # Update the config file with the new proxy
  echo "http $proxy_address $proxy_auth" > $proxychains_config
}

# Main script logic
while true; do
  proxy=$(get_new_proxy)
  update_proxychains_config "$proxy"
  
  # Start your local server using proxychains
  proxychains python3 -m http.server 6789
  sleep 200
done
