//

const Koa = require('koa');
const Router = require('@koa/router');
const { Sequelize, DataTypes } = require('sequelize');
const Redis = require('ioredis');
const os = require('os');
const cluster = require('cluster');

const numCPUs = os.cpus().length;
const app = new Koa();
const router = new Router();
const sequelize = new Sequelize('testdb', null, null, {
  host: '/tmp',
  dialect: 'postgresql',
  logging: false,
  // pool: {
  //   max: 5,
  //   min: 0,
  //   idle: 10000
  // }
});
const redis = new Redis();

const Item = sequelize.define('items', {
  title: {
    type: DataTypes.STRING
  }
}, {
  timestamps: false
});

router.get('/json', (ctx) => {
  ctx.body = { hello: 'world' };
});

router.get('/select', async (ctx) => {
  item = await Item.findByPk(1)
  ctx.body = item
});

router.get('/update', async (ctx) => {
  item = await Item.findByPk(1)
  item.title = item.title.split('').reverse().join('')
  await item.save()
  ctx.body = item
});

router.get('/get', async (ctx) => {
  const result = await redis.get('hello');
  ctx.body = { hello: result };
});

app
  .use(router.routes())
  .use(router.allowedMethods());

if (cluster.isMaster) {
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
} else {
  app.listen(process.env['PORT'] || '/tmp/test.sock');
}

