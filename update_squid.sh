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

proxy_info=$(get_new_proxy)
proxy_ip=$(echo "$proxy_info" | cut -d ':' -f 1)
proxy_port=$(echo "$proxy_info" | cut -d ':' -f 2)
proxy_credentials=$(echo "$proxy_info" | cut -d ':' -f 3-4)

# Backup current squid.conf file
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

# Write new configuration to squid.conf
sudo bash -c "cat > /etc/squid/squid.conf << EOF
http_port 3128
http_access allow all
cache_peer $proxy_ip parent $proxy_port 0 no-query default login=$proxy_credentials
never_direct allow all
EOF"

# Restart Squid service
sudo systemctl restart squid
