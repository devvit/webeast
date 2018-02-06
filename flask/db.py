#

import redis

from peewee import Model, CharField
from playhouse.flask_utils import FlaskDB
# from playhouse.pool import PooledPostgresqlExtDatabase
# MySQLDatabase

pool_size = 20
# db = MySQLDatabase('testdb', host='localhost', user='root', password='')
# db = PooledPostgresqlExtDatabase('testdb', host='/tmp', autocommit=True, autorollback=True, max_connections=pool_size)
db_wrapper = FlaskDB()
rds_pool = redis.ConnectionPool(max_connections=pool_size)
rds = redis.Redis(unix_socket_path='/tmp/redis.sock', decode_responses=True, connection_pool=rds_pool)


class Item(db_wrapper.Model):
    title = CharField()

    class Meta:
        # database = db_wrapper
        db_table = 'items'
