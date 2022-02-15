#

# ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

# LockAndCache.storage = Redis.new

class SinatraApp < Sinatra::Base
  # KACHE = ActiveSupport::Cache.lookup_store :dalli_store, race_condition_ttl: 10

  configure do
    disable :static
    disable :protection
  end

  after do
    ActiveRecord::Base.clear_active_connections!
  end

  get '/json' do
    { hello: 'world' }.to_json
  end

  get '/get' do
    REDIS.with do |conn|
      conn.get('mydata')
    end
  end

  get '/set' do
    REDIS.with do |conn|
      conn.set('uid', request.env['HTTP_X_REQUEST_ID'])
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
    KACHE.fetch('wtf', expires_in: 20) {
      for i in (0..500000000) do

      end

      "game over #{Time.now.to_f}"
    }
  end

  get '/rest' do
    s = HTTP.get("http://twitter.com")
    {size: s.to_s.size}.to_json
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

  get '/gems' do
    Gem.loaded_specs.keys.to_json
  end
end
