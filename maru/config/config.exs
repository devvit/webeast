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

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :myweb, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:myweb, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :maru, Myweb.Apiv1, http: [port: 3000, ip: {0,0,0,0}]
