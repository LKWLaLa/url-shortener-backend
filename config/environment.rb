require 'rubygems'
require 'bundler'

ENV['SINATRA_ENV'] ||= "development"
Bundler.require(:default, ENV['SINATRA_ENV'])

require_relative '../app/helpers/application_helper.rb'
require_relative '../app/app.rb'
