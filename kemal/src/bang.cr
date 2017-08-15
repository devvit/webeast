require "./bang/*"

require "kemal"
require "json"
require "redisoid"
require "active_record"
require "postgres_adapter"

rds = Redisoid.new(unixsocket: "/tmp/redis.sock", pool: 10)

Kemal.config.logging = false
Kemal.config.port = ENV["PORT"].to_i

class Item < ActiveRecord::Model
  adapter postgres

  table_name "items"

  primary id : Int
  field title : String
end

module Bang
  # TODO Put your code here

  get "/json" do
    {hello: "world"}.to_json
  end

  get "/get" do
    rds.get("mydata")
  end

  get "/select" do
    item = Item.get(1)
    if item != nil
      item.as(Item)
      {id: item.id, title: item.title}
    end
  end
end

get "/update" do
  item = Item.get(1)
  if item != nil
    item.as(Item)
    item.title = "#{item.title}".reverse
    item.update
    {id: item.id, title: item.title}
  end
end

Kemal.run
