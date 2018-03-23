#

import aioredis
import peewee
import peewee_async

db = peewee_async.PooledPostgresqlDatabase(
    'testdb',
    host='/tmp',
    autocommit=True,
    autorollback=True,
    max_connections=10
)
db.set_allow_sync(False)
objs = peewee_async.Manager(db)


async def init_redis(app, loop):
    app.redis_pool = await aioredis.create_redis_pool(
        '/tmp/redis.sock',
        encoding='utf-8',
        minsize=1,
        maxsize=10,
        loop=loop
    )


class Item(peewee.Model):
    title = peewee.CharField()

    class Meta:
        database = db
        db_table = 'items'
