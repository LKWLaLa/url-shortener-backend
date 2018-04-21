require './config/environment'

class Application < Sinatra::Base
  register Sinatra::CrossOrigin

  configure do
    enable :cross_origin
    $redis = Redis.new
  end

  helpers do
    def generate_short_url
      chars_arr = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B',
        'C','D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q',
        'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0','1', '2', '3', '4', '5',
        '6', '7', '8', '9']

        short_url = 7.times.map{ chars_arr.sample }.join
        $redis.hexists("short_keys", short_url) ? generate_short_url : short_url
    end
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


  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"   
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
   200
  end
 

end












