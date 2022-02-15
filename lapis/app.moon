--

lapis = require 'lapis'

import Model from require 'lapis.db.model'
import get_redis from require 'lapis.redis'

class Items extends Model
  foo = 'bar'

class extends lapis.Application
  '/json': =>
    json: { hello: 'world' }

  '/select': =>
    item = Items\find 1
    json: { id: item.id, title: item.title }

  '/update': =>
    item = Items\find 1
    item.title = item.title\reverse!
    item\update 'title'
    json: { id: item.id, title: item.title }

  '/get': =>
    redis = get_redis!
    json: { hello: redis\get('hello') }
