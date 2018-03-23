#

import socket

from sanic import Sanic
from sanic import response

from db import init_redis, objs, Item

app = Sanic(__name__, log_config=None)
app.config['KEEP_ALIVE_TIMEOUT'] = 30


@app.listener('before_server_start')
async def before_server_start(app, loop):
    await init_redis(app, loop)


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
