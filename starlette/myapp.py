#

from starlette.applications import Starlette
from starlette.responses import JSONResponse
from starlette.routing import Route
import aioredis
import databases
import orm

database = databases.Database('postgres://localhost:5432/testdb')
models = orm.ModelRegistry(database=database)
pool = aioredis.BlockingConnectionPool.from_url(
    "redis://localhost", max_connections=10, decode_responses=True)
redis = aioredis.Redis(connection_pool=pool)


class Item(orm.Model):
    tablename = "items"
    registry = models
    fields = {
        "id": orm.Integer(primary_key=True),
        "title": orm.String(max_length=100)
    }


async def json_handle(request):
    return JSONResponse({'hello': 'world'})


async def get_handle(request):
    val = await redis.get('hello')
    return JSONResponse({'hello': val})


async def select_handle(request):
    item = await Item.objects.get(id=1)
    return JSONResponse({'id': item.id, 'title': item.title})


async def update_handle(request):
    item = await Item.objects.get(id=1)
    await item.update(title=item.title[::-1])
    return JSONResponse({'id': item.id, 'title': item.title})


async def startup():
    await database.connect()


app = Starlette(debug=False, routes=[
                Route('/json', json_handle),
                Route('/get', get_handle),
                Route('/select', select_handle),
                Route('/update', update_handle),
                ], on_startup=[startup])
