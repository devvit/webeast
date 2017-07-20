--

memcached = if ngx then require "resty.memcached"

memcached_down = nil

connect_memcached = ->
  r = memcached\new!
  ok, err = r\connect '127.0.0.1', 11211
  if ok
    r
  else
    memcached_down = ngx.time!
    ok, err

get_memcached = ->
  return if memcached_down and memcached_down + 60 > ngx.time!

  r = ngx.ctx.memcached
  unless r
    import after_dispatch from require "lapis.nginx.context"

    r, err = connect_memcached!

    if r
      ngx.ctx.memcached = r
      after_dispatch ->
        r\set_keepalive!
        ngx.ctx.memcached = nil

  r

{ :get_memcached }

