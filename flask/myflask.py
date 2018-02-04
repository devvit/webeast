#

import json

import requests

from flask import Flask, request

from db import db_wrapper, Item, rds, pool_size

app = Flask(__name__)
app.config['DATABASE'] = {
    'name': 'testdb',
    'engine': 'playhouse.pool.PooledPostgresqlDatabase',
    'host': '/tmp',
    'max_connections': pool_size,
    'autocommit': True,
    'autorollback': True
}
db_wrapper.init_app(app)


@app.route('/json')
def my_json():
    return json.dumps({'hello': 'world'})


@app.route('/get')
def my_redis_get():
    return rds.get('mydata')


@app.route('/set')
def my_redis_set():
    return str(rds.set('uid', request.headers.get('X-Request-Id')))


@app.route('/rest')
def my_rest():
    res = requests.get('http://twitter.com')
    return json.dumps({'id': len(res.text)})


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
