import aiohttp
import asyncio
import json
import os
import logging
import time

from aiohttp import web

# Prompt user to enter their API key
API_KEY = input("Enter your API Key: ")

PORT = int(os.getenv('PORT', '6789'))  # read port number from environment variables

logging.basicConfig(level=logging.INFO)  # configure logging
logger = logging.getLogger(__name__)

proxy_data = None

async def fetch_proxy(session):
    url = f"https://api.tinproxy.com/proxy/get-new-proxy?api_key={API_KEY}"
    try:
        async with session.get(url) as response:
            data = await response.text()
            return json.loads(data)['data']
    except Exception as e:
        logger.error(f"Failed to fetch proxy: {e}")
        return None

async def update_proxy_data():
    async with aiohttp.ClientSession() as session:
        while True:
            global proxy_data
            new_proxy_data = await fetch_proxy(session)
            if new_proxy_data is not None:
                proxy_data = new_proxy_data
            else:
                logger.info("Using previous proxy due to error when fetching new proxy")
            await asyncio.sleep(200)

async def handler(request):
    # Use aiohttp.ClientSession as a proxy client
    async with aiohttp.ClientSession() as session:
        http_proxy = f"http://{proxy_data['authentication']['username']}:{proxy_data['authentication']['password']}@{proxy_data['http_ipv4']}"

        # Prepare the request to be sent via the proxy
        url = str(request.url)
        headers = {k: v for k, v in request.headers.items() if k.lower() != 'host'}
        proxy_req = getattr(session, request.method.lower())
        try:
            async with proxy_req(url, headers=headers, proxy=http_proxy) as resp:
                body = await resp.read()
                return web.Response(body=body, status=resp.status)
        except Exception as e:
            logger.error(f"Failed to handle request: {e}")
            return web.Response(text="Failed to handle request", status=500)

app = web.Application()
app.router.add_route('*', '/{tail:.*}', handler)

# Run the server
loop = asyncio.get_event_loop()
loop.create_task(update_proxy_data())
web.run_app(app, port=PORT)
