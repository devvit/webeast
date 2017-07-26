#

# ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

ActiveRecord::Base.establish_connection({
  adapter: 'postgresql',
  database: 'testdb',
  host: '/tmp'
})

# LockAndCache.storage = Redis.new

class Item < ActiveRecord::Base

end

class App < Sinatra::Base
  REDIS = ConnectionPool::Wrapper.new(size: 10, timeout: 3) { Redis.connect path: '/tmp/redis.sock', driver: :hiredis }
  # KACHE = ActiveSupport::Cache.lookup_store :dalli_store, race_condition_ttl: 10

  configure do
    disable :static
    disable :protection
  end

  get '/json' do
    { hello: 'world' }.to_json
  end

  get '/redis' do
    REDIS.with do |conn|
      conn.get('mydata')
    end
  end

  get '/lock_x' do
    LockAndCache.lock_and_cache :wtf, expires: 10 do
      puts '------ ------ ------'

      for i in (0..500000000) do

      end

      "game over #{Time.now.to_f}"
    end
  end

  get '/lock' do
    KACHE.fetch 'wtf', expires_in: 20 {
      for i in (0..500000000) do

      end

      "game over #{Time.now.to_f}"
    }
  end

  get '/rest' do
    s = RestClient.get("http://twitter.com")
    {size: s.body.size}.to_json
  end

  get '/select' do
    item = Item.find(1)

    item.to_json
  end

  get '/update' do
    item = Item.find(1)
    item.title = item.title.reverse
    item.save

    item.to_json
  end
end
