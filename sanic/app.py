#

import socket

import aioredis
import peewee
import peewee_async

from sanic import Sanic
from sanic import response

app = Sanic(__name__)
db = peewee_async.PooledPostgresqlDatabase(
    'testdb',
    host='localhost',
    autorollback=True,
    max_connections=5
)
db.set_allow_sync(False)
objs = peewee_async.Manager(db)


class Item(peewee.Model):
    title = peewee.CharField()

    class Meta:
        database = db
        db_table = 'items'


@app.listener('before_server_start')
async def before_server_start(app, loop):
    app.redis_pool = await aioredis.create_pool(
        ('localhost', 6379),
        encoding='utf-8',
        minsize=1,
        maxsize=5,
        loop=loop
    )


@app.route('/json')
async def test_json(request):
    return response.json({'hello': 'world'})


@app.route('/redis')
async def test_redis(request):
    async with request.app.redis_pool.get() as redis:
        val = await redis.get('mydata')
        return response.text(val)


@app.route('/select')
async def test_select(request):
    item = await objs.get(Item, Item.id == 1)
    return response.json({'id': item.id, 'title': item.title})


@app.route('/update')
async def test_update(request):
    item = await objs.get(Item, Item.id == 1)
    item.title = item.title[::-1]
    await objs.update(item)
    return response.json({'id': item.id, 'title': item.title})

if __name__ == '__main__':
    usock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    usock.bind('/tmp/test.sock')
    app.run(
        # sock=usock,
        debug=False,
        log_config=None,
        workers=2,
        host='0.0.0.0',
        port=3000
    )
