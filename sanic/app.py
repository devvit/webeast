#

import socket

import aioredis
import peewee
import peewee_async

from sanic import Sanic
from sanic import response

app = Sanic(__name__, log_config=None)
app.config['KEEP_ALIVE_TIMEOUT'] = 30
db = peewee_async.PooledPostgresqlDatabase(
    'testdb',
    host='/tmp',
    autocommit=True,
    autorollback=True,
    max_connections=10
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
    app.redis_pool = await aioredis.create_redis_pool(
        '/tmp/redis.sock',
        encoding='utf-8',
        minsize=1,
        maxsize=10,
        loop=loop
    )


@app.route('/json')
async def test_json(request):
    return response.json({'hello': 'world'})


@app.route('/get')
async def test_redis_get(request):
    val = await request.app.redis_pool.get('mydata')
    return response.text(val)


@app.route('/set')
async def test_redis_set(request):
    val = await request.app.redis_pool.set('uid', request.headers.get('X-Request-Id'))
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
        sock=usock,
        debug=False,
        access_log=False,
        # log_config=None,
        workers=2,
        host=None,
        port=None
    )
