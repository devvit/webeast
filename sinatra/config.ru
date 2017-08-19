#

require 'bundler'

Bundler.require :default, ENV['RACK_ENV'] || 'development'

require './db'
require './sinatra_app'
require './roda_app'

if ENV['APP'] == roda
  run RodaApp.freeze.app
else
  run SinatraApp
end
