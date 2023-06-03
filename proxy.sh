#!/bin/bash

# API configuration
API_KEY=""

# Local server configuration
LOCAL_SERVER_PORT="6789"

# Get API key from user input
echo "Enter your API key:"
read -r API_KEY

# Proxy forwarding
while true; do
   # Get new proxy
   response=$(curl -s "https://api.tinproxy.com/proxy/get-new-proxy?api_key=$API_KEY")
   proxy_http=$(echo "$response" | jq -r '.data.http_ipv4')
   proxy_username=$(echo "$response" | jq -r '.data.authentication.username')
   proxy_password=$(echo "$response" | jq -r '.data.authentication.password')

   # Forward proxy to local server
   socat TCP-LISTEN:$LOCAL_SERVER_PORT,fork PROXY:$proxy_http,proxyport=$LOCAL_SERVER_PORT,proxyauth=$proxy_username:$proxy_password &

   # Wait for 200 seconds
   sleep 200

   # Terminate the socat process
   pkill socat
done
