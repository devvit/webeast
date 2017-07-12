#

import json

from flask import Flask

from db import Item, rds

app = Flask(__name__)


@app.route('/json')
def my_json():
    return json.dumps({'hello': 'world'})


@app.route('/redis')
def my_redis():
    return rds.get('mydata')


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
