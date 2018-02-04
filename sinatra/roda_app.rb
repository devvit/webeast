#

class RodaApp < Roda
  plugin :hooks
  plugin :json

  after do
    ActiveRecord::Base.clear_active_connections!
  end

  route do |r|

    r.get 'json' do
      { hello: 'world' }.to_json
    end

    r.get 'get' do
      REDIS.with do |conn|
        conn.get('mydata')
      end
    end

    r.get 'select' do
      item = Item.find(1)

      item.to_json
    end

    r.get 'update' do
      item = Item.find(1)
      item.title = item.title.reverse
      item.save

      item.to_json
    end

  end
end
