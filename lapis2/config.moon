--

config = require 'lapis.config'

config { 'development', 'test', 'production' }, ->
  num_workers 'auto'
  code_cache 'on'
  postgres ->
    host 'unix:/tmp/.s.PGSQL.5432'
    user os.getenv('USER')
    database 'testdb'
  redis ->
    host 'unix:/tmp/redis.sock'

config 'development', ->
  secret 'development_secret'
  num_workers 1
  code_cache 'off'

config 'production', ->
  secret 'production_secret'

config 'test', ->
  secret 'test_secret'
  num_workers 1
