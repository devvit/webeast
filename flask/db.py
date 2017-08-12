#

import redis

from peewee import Model, CharField, PostgresqlDatabase
# MySQLDatabase

# db = MySQLDatabase('testdb', host='localhost', user='root', password='')
db = PostgresqlDatabase('testdb', host='/tmp', autocommit=True, autorollback=True)
rds = redis.Redis(unix_socket_path='/tmp/redis.sock', decode_responses=True)


class Item(Model):
    title = CharField()

    class Meta:
        database = db
        db_table = 'items'
