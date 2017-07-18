#

import redis

from peewee import Model, CharField, PostgresqlDatabase
# MySQLDatabase

# db = MySQLDatabase('testdb', host='localhost', user='root', password='')
db = PostgresqlDatabase('testdb', host='localhost')
rds = redis.Redis(decode_responses=True)


class Item(Model):
    title = CharField()

    class Meta:
        database = db
        db_table = 'items'
