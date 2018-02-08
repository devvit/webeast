#

import json

import redis

from bottle import Bottle, request, hook
from playhouse.pool import PooledPostgresqlExtDatabase
from playhouse.postgres_ext import Model, CharField

from db import Item, rds

pool_size = 20
db = PooledPostgresqlExtDatabase('testdb', host='/tmp', autocommit=True, autorollback=True, max_connections=pool_size)
rds_pool = redis.ConnectionPool(max_connections=pool_size)
rds = redis.Redis(unix_socket_path='/tmp/redis.sock', decode_responses=True, connection_pool=rds_pool)
app = Bottle()


class Item(Model):
    title = CharField()

    class Meta:
        database = db
        db_table = 'items'


@hook('before_request')
def _connect_db():
    db._connect()


@hook('after_request')
def _close_db():
    db._close()


@app.route('/json')
def my_json():
    return json.dumps({'hello': 'world'})


@app.route('/get')
def my_redis_get():
    return rds.get('mydata')


@app.route('/set')
def my_redis_set():
    return str(rds.set('uid', request.headers.get('X-Request-Id')))


@app.route('/select')
def my_select():
    item = Item.get(Item.id == 1)
    return json.dumps({'id': item.id, 'title': item.title})


@app.route('/update')
def my_update():
    item = Item.get(Item.id == 1)
    item.title = item.title[::-1]
    item.save()
    return json.dumps({'id': item.id, 'title': item.title})
