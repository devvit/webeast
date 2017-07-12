#

Sequel::Model.plugin :json_serializer

Sequel.connect(ENV['DATABASE_URL'], max_connections: 10)

class Item < Sequel::Model

end

class App < Sinatra::Base
	REDIS = ConnectionPool::Wrapper.new(size: 10, timeout: 3) { Redis.connect driver: :hiredis }
  # REDIS = ConnectionPool::Wrapper.new(size: 10, timeout: 3) { Redis.connect }

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
    item = Item[1]

    item.to_json
  end

  get '/update' do
    item = Item[1]
    item.title = item.title.reverse
    item.save

    item.to_json
  end
end
