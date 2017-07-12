#

require 'bundler'

Bundler.require :default, ENV['RACK_ENV'] || 'development'

require './app'

run App
