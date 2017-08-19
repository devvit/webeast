#

require 'bundler'

Bundler.require :default, ENV['RACK_ENV'] || 'development'

require './db'
require './sinatra_app'
require './roda_app'

if ENV['APP'] == 'roda'
  puts 'start roda'
  run RodaApp.freeze.app
else
  puts 'start sinatra'
  run SinatraApp
end
