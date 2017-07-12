#

require 'bundler'

Bundler.require :default, ENV['RACK_ENV'] || 'development'

# Thin::Logging.silent = true

require './app'

run App
