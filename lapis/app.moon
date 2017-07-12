--

lapis = require "lapis"
redis = require 'resty.redis'

import to_json from require 'lapis.util'
import Model from require 'lapis.db.model'
import get_redis from require 'redis_cache'

class Items extends Model
  foo = 'bar'

class extends lapis.Application
  '/json': =>
    json: { hello: 'world' }

  '/redis': =>
    rds = get_redis!
    render: false, layout: false, rds\get 'mydata'

  '/select': =>
    item = Items\find 1
    json: { id: item.id, title: item.title }

  '/update': =>
    item = Items\find 1
    item.title = item.title\reverse!
    item\update 'title'
    json: { id: item.id, title: item.title }
