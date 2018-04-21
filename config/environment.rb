require 'rubygems'
require 'bundler'

ENV['SINATRA_ENV'] ||= "development"
Bundler.require(:default, ENV['SINATRA_ENV'])

require_relative '../app/app.rb'