# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :myweb, Myweb.Repo, [
  adapter: Ecto.Adapters.Postgres,
  database: "testdb",
  username: "foo",
  password: "",
  hostname: "localhost",
  loggers: [],
  pool_size: 10
]

config :myweb, ecto_repos: [Myweb.Repo]

config :logger, level: :error

config :redis_pool, :pools, [
  rds: [size: 10, host: '127.0.0.1', port: 6379]
]

config :memcachir, hosts: "localhost", pool: [size: 10, max_overflow: 10, strategy: :lifo]

config :maru, Myweb.Apiv1, http: [
  port: 3000,
  ip: {0,0,0,0},
  protocol_options: [
    max_keepalive: 5_000_000
  ]
]
