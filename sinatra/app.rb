#

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

class Item < ActiveRecord::Base

end

class App < Sinatra::Base
  REDIS = ConnectionPool::Wrapper.new(size: 10, timeout: 3) { Redis.connect driver: :hiredis }

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
