const Koa = require('koa');
const Router = require('@koa/router');

const app = new Koa();
const router = new Router();

router.get('/', (ctx, next) => {
  ctx.body = 'hello world';
});

app
  .use(router.routes())
  .use(router.allowedMethods());

app.listen(1433, '0.0.0.0');
