--

config = require 'lapis.config'

config { 'development', 'test', 'production' }, ->
  num_workers 'auto'
  code_cache 'on'
  port 80
  postgres ->
    host '192.168.56.105'
    user 'postgres'
    database 'dem0_development'

config 'development', ->
  secret 'development_secret'
  num_workers 1
  code_cache 'off'

config 'production', ->
  secret 'production_secret'

config 'test', ->
  secret 'test_secret'
  num_workers 1
