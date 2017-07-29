--

config = require 'lapis.config'

config {'development', 'production', 'test'}, ->
  secret 'mysecret'
  postgres ->
    host 'unix:/tmp/.s.PGSQL.5432'
    user 'foo'
    database 'testdb'

config 'development', ->
  port 9090
  num_workers 1
  daemon 'off'
  mysql ->
    path '/tmp/mysql.sock'
    user 'root'
    database 'testdb'

config 'production', ->
  port 9090
  num_workers 2
  daemon 'off'
  code_cache 'on'

config 'test', ->
  port 9090
