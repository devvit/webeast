#!/usr/bin/env bash

redis_conf="
daemonize yes
unixsocket /tmp/redis.sock
unixsocketperm 700
"

echo "$redis_conf" >/tmp/redis.conf

redis-server /tmp/redis.conf
