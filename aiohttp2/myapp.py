#

import asyncio
import uvloop

from aiohttp import web

async def json_handle(request):
    return web.json_response({ 'hello': 'world' })

async def app_factory():
    app = web.Application()
    app.add_routes([
        web.get('/', json_handle)
    ])
    return app

if __name__ == '__main__':
    asyncio.get_event_loop().close()
    asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
    web.run_app(app_factory(), port=80)
