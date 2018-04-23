require './config/environment'

class Application < Sinatra::Base
  register Sinatra::CrossOrigin
  helpers ApplicationHelper

  configure do
    enable :cross_origin
    $redis = Redis.new(url: ENV["REDIS_URL"])
  end

  get '/' do
    "Welcome to Shrink Me!  (Lindsey's URL shortener) 
    There is nothing to see at the index route!  You can try navigating to '/top-100',
    or making a POST request to '/urls', with a body/payload format of {url: 'https://example.com'}."
  end

  # The Redis store includes two hash tables:  The first exists at the key
  # "short_keys", and contains keys which are the shortened version of a URL,
  # with values that are the full URL.  The second hash table, at "long_keys",
  # is the opposite.  The keys are the full version of the URL and the values
  # are the shortened versions. 
  
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

  get '/top-100' do
    parse_top_100.to_json
  end

  get '/:short_url' do
    short_url = params[:short_url]
    if full_url = $redis.hget("short_keys", short_url)
      update_frequency(short_url)
      add_to_top_100(short_url) if valid_top_100?(short_url)
      prune_top_100
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












