--

lapis = require "lapis"
redis = require 'resty.redis'

import to_json from require 'lapis.util'
import Model from require 'lapis.db.model'
import get_redis from require 'redis_cache'
import get_memcached from require 'mc'

class Items extends Model
  foo = 'bar'

class extends lapis.Application
  '/json': =>
    json: { hello: 'world' }

  '/redis': =>
    rds = get_redis!
    render: false, layout: false, rds\get 'mydata'

  '/mc_set': =>
    mc = get_memcached!
    v, err = mc\set 'testkey', "hello, #{ngx.time!}\n"
    render: false, layout: false, "result: #{v}\n"

  '/mc': =>
    mc = get_memcached!
    v, err = mc\get 'testkey'
    render: false, layout: false, "#{v}"

  '/select': =>
    item = Items\find 1
    json: { id: item.id, title: item.title }

  '/update': =>
    item = Items\find 1
    item.title = item.title\reverse!
    item\update 'title'
    json: { id: item.id, title: item.title }
