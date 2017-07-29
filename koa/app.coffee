#

Koa = require 'koa'
Router = require 'koa-router'
Sequelize = require 'sequelize'
# Memcached = require 'memcached'

# memcached = new Memcached 'localhost:11211', {
# poolSize: 3
# }

# http = require('uws').http

rpool = require '@npmcorp/redis-pool'

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

api.get '/get', (ctx) =>
  ctx.body = await rpool.withConnection (rds) =>
    rds.getAsync 'mydata'

api.get '/set', (ctx) =>
  ctx.body = await rpool.withConnection (rds) =>
    rds.setAsync 'uid', ctx.headers['x-request-id']

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

# http.createServer(app.callback()).listen(3000)
app.listen process.argv[2]
