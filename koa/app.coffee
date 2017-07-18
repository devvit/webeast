#

Koa = require 'koa'
Router = require 'koa-router'
Sequelize = require 'sequelize'
Memcached = require 'memcached'

memcached = new Memcached 'localhost:11211', {
  poolSize: 3
}

redis = require 'thunk-redis'
rds = redis.createClient { usePromise: true }

# Redis = require 'ioredis'
# redis = new Redis

redisPool = require('redis-connection-pool')('myRedisPool', {
  host: 'localhost',
  port: 6379,
  max_clients: 2
})

sequelize = new Sequelize 'postgres://localhost/testdb', {
  logging: false,
  pool: {
    max: 5,
    min: 0,
    idle: 10000
  }
}

Item = sequelize.define 'items', {
  title: {
    type: Sequelize.STRING
  }
}, {
  timestamps: false
}

app = new Koa
api = new Router
app.use api.routes()

api.get '/json', (ctx) =>
  ctx.body = { hello: 'world' }

api.get '/redis_t', (ctx) =>
  ctx.body = await rds.get 'mydata'

api.get '/redis', (ctx) =>
  ctx.body = await new Promise (resolve, reject) =>
    redisPool.get 'mydata', (err, reply) =>
      if err
        reject err
      else
        resolve reply
  # ctx.body = await redis.get 'mydata'

api.get '/select', (ctx) =>
  item = await Item.findById 1, { attributes: ['id', 'title'] }
  ctx.body = item

api.get '/update', (ctx) =>
  item = await Item.findById 1, { attributes: ['id', 'title'] }
  item.title = item.title.split('').reverse().join('')
  await item.save fields: ['title']
  ctx.body = item

api.get '/mc_set', (ctx) =>
  ctx.body = await new Promise (resolve, reject) =>
    memcached.set 'testkey', 'hEllO, wOrld.', 3600, (err) =>
      if err
        reject err
      else
        resolve 'ok'

api.get '/mc', (ctx) =>
  ctx.body = await new Promise (resolve, reject) =>
    memcached.get 'testkey', (err, data) =>
      if err
        reject err
      else
        resolve data

# app.listen process.argv[2]
app.listen 3000
