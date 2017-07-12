--

config = require 'lapis.config'

config {'development', 'production', 'test'}, ->
  secret 'mysecret'
  postgres ->
    host '127.0.0.1'
    user 'foo'
    database 'testdb'

config 'development', ->
  port 9090
  num_workers 1
  daemon 'off'

config 'production', ->
  port 9090
  num_workers 2
  daemon 'off'
  code_cache 'on'

config 'test', ->
  port 9090
