#!/bin/bash

# Read the API key
read -p "Enter your API Key: " api_key

# The location of the Squid configuration file
squid_config="/etc/squid/squid.conf"

while true; do
    # Get a new proxy from tinproxy
    response=$(curl -s "https://api.tinproxy.com/proxy/get-new-proxy?api_key=$api_key")
    http_ipv4=$(echo "$response" | jq -r '.data.http_ipv4')
    username=$(echo "$response" | jq -r '.data.authentication.username')
    password=$(echo "$response" | jq -r '.data.authentication.password')

    # Extract the proxy address and port
    proxy_address=$(echo $http_ipv4 | cut -d ':' -f 1)
    proxy_port=$(echo $http_ipv4 | cut -d ':' -f 2)

    # Update the Squid configuration file with the new proxy details
    sed -i "s/^cache_peer .*/cache_peer $proxy_address parent $proxy_port 0 no-query default login=$username:$password/" $squid_config

    # Restart Squid to apply the new proxy
    systemctl restart squid

    # Wait 200 seconds before getting a new proxy
    sleep 200
done
