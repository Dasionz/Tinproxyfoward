#!/bin/bash

API_KEY=""
LOCAL_PORT=6789
REFRESH_INTERVAL=100

# Get user input for API key
read -p "Enter your Tinproxy API key: " API_KEY

while true; do
    # Get new proxy
    response=$(curl -s "https://api.tinproxy.com/proxy/get-new-proxy?api_key=$API_KEY")
    proxy_address=$(echo "$response" | jq -r '.data.http_ipv4')
    proxy_port=$(echo "$response" | jq -r '.data.http_ipv4' | cut -d ':' -f 2)
    username=$(echo "$response" | jq -r '.data.authentication.username')
    password=$(echo "$response" | jq -r '.data.authentication.password')

    # Forward the proxy to the local server
    ssh -L $LOCAL_PORT:$proxy_address:$proxy_port -N -f -L $proxy_address:$proxy_port:$proxy_address:$proxy_port $username@$proxy_address -p $proxy_port -o StrictHostKeyChecking=no

    # Wait for the specified interval
    sleep $REFRESH_INTERVAL

    # Terminate the SSH tunnel
    kill $(pgrep -f "ssh -L")
done
