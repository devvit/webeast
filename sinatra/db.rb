#
# test git

POOL_SIZE = 20

ActiveRecord::Base.establish_connection({
  adapter: 'postgresql',
  database: 'testdb',
  host: '/tmp',
  pool: POOL_SIZE
})

REDIS = ConnectionPool::Wrapper.new(size: POOL_SIZE, timeout: 3) { Redis.new path: '/tmp/redis.sock', driver: :hiredis }

class Item < ActiveRecord::Base; end
