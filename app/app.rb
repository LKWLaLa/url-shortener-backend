require './config/environment'

class Application < Sinatra::Base

  redis = Redis.new

  get "/" do
    redis.ping
  end

end












