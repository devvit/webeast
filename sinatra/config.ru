#

require 'bundler'

Bundler.require :default, ENV['RACK_ENV'] || 'development'

require './db'
require './sinatra_app'

run SinatraApp
