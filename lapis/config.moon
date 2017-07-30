--

config = require 'lapis.config'

config {'development', 'production', 'test'}, ->
  secret 'mysecret'
  postgres ->
    host 'unix:/tmp/.s.PGSQL.5432'
    user 'foo'
    database 'testdb'

config 'development', ->
  num_workers 1
  daemon 'off'
  mysql ->
    path '/tmp/mysql.sock'
    user 'root'
    database 'testdb'

config 'production', ->
  num_workers 2
  daemon 'off'
  code_cache 'on'

config 'test', ->
  code_cache 'off'
