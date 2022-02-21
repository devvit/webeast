--

config = require 'lapis.config'

config { 'development', 'test', 'production' }, ->
  code_cache 'on'
  postgres ->
    host 'unix:/tmp/.s.PGSQL.5432'
    user os.getenv('USER')
    database 'testdb'
    -- pool_size 1
    -- backlog 2
  redis ->
    host 'unix:/tmp/redis.sock'

config 'development', ->
  secret 'development_secret'
  code_cache 'off'

config 'production', ->
  secret 'production_secret'

config 'test', ->
  secret 'test_secret'
