require './config/environment'

class Application < Sinatra::Base
  register Sinatra::CrossOrigin
  helpers ApplicationHelper

  configure do
    enable :cross_origin
    $redis = Redis.new(url: ENV["REDIS_URL"])
  end
  
  post '/urls' do
    request.body.rewind
    @payload = JSON.parse request.body.read
    if @payload['url'] && !@payload['url'].empty?
      full_url = @payload['url'] 
      if $redis.hexists("long_keys", full_url) 
        short_url = $redis.hget("long_keys", full_url)
      else
        short_url = generate_short_url
        $redis.hset("long_keys", full_url, short_url)
        $redis.hset("short_keys", short_url, full_url)
      end
      short_url.to_json 
    end
  end

  get '/:short_url' do
    short_url = params[:short_url]
    if full_url = $redis.hget("short_keys", short_url)
      update_frequency(short_url)
      #must begin with http or https, otherwise it will look for route within this domain
      redirect full_url
    else
      status 404
      body "404 error: Apologies, we cannot seem to find that short link."
    end
  end


  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"   
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
   200
  end
 

end












