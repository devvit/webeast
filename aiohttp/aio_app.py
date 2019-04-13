#

import asyncio
import json

import aioredis
import uvloop

from aiohttp import web

from db import init_redis, objs, Item


async def json_handle(request):
    return web.Response(text=json.dumps({ 'hello': 'world' }))


async def get_handle(request):
    val = await request.app.redis_pool.get('mydata')
    return web.Response(text=val)


async def select_handle(request):
    item = await objs.get(Item, Item.id == 1)
    return web.json_response({'id': item.id, 'title': item.title})


async def update_handle(request):
    item = await objs.get(Item, Item.id == 1)
    item.title = item.title[::-1]
    await objs.update(item)
    return web.json_response({'id': item.id, 'title': item.title})


async def app_factory():
    app = web.Application()
    await init_redis(app, app.loop)
    app.add_routes([
        web.get('/json', json_handle),
        web.get('/get', get_handle),
        web.get('/select', select_handle),
        web.get('/update', update_handle)
    ])
    return app

if __name__ == '__main__':
    asyncio.get_event_loop().close()
    asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
    web.run_app(app_factory())
