#

import asyncio
import aioredis
import uvloop

from aiohttp import web
import databases
import orm

database = databases.Database('postgres://localhost:5432/testdb')
models = orm.ModelRegistry(database=database)


class Item(orm.Model):
    tablename = "items"
    registry = models
    fields = {
        "id": orm.Integer(primary_key=True),
        "title": orm.String(max_length=100)
    }


async def init_redis(app):
    pool = aioredis.BlockingConnectionPool.from_url(
        "redis://localhost", max_connections=10, decode_responses=True)
    app.redis = aioredis.Redis(connection_pool=pool)


async def get_handle(request):
    val = await request.app.redis.get('hello')
    return web.json_response({'hello': val})


async def json_handle(request):
    return web.json_response({'hello': 'world'})


async def select_handle(request):
    item = await Item.objects.get(id=1)
    return web.json_response({'id': item.id, 'title': item.title})


async def update_handle(request):
    item = await Item.objects.get(id=1)
    await item.update(title=item.title[::-1])
    return web.json_response({'id': item.id, 'title': item.title})


async def app_factory():
    app = web.Application()
    app.add_routes([
        web.get('/json', json_handle),
        web.get('/get', get_handle),
        web.get('/select', select_handle),
        web.get('/update', update_handle)
    ])
    await init_redis(app)
    await database.connect()
    return app

if __name__ == '__main__':
    asyncio.get_event_loop().close()
    asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
    web.run_app(app_factory(), port=80)
