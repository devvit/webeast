#

import json

import requests

from flask import Flask, request

from db import Item, rds

app = Flask(__name__)


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
