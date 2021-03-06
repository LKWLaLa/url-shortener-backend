require './config/environment'

module ApplicationHelper 
  
  # Definition of redis data structures included:
  # "short_keys" - hash with the structure {short_url : full_url}
  # "long_keys" - hash with the structure {full_url : short_url}
  # "frequency" - hash with the structure {short_url : number of hits}
  # "top_100" - sorted set, where member = short_url and score = frequency (number of hits)
  # "minimum_frequency" - a simple key, value pair that holds a counter of the lowest
  # score / frequency value in the "top_100" sorted set.  
  # "url_iteration" - list of integers (in string form) representing the latest iteration of a short_url,
  # the starting point being {"url_iteration" : [0]}

  def generate_short_url
    # is there a better way to store this data?
    arr = map_url_iteration_from_redis_to_int_array
    short_url = map_ints_to_chars(arr)
    new_arr = increment(arr) 
    $redis.del("url_iteration")
    $redis.rpush("url_iteration", new_arr)
    short_url
  end
  
  def increment(arr, index = 0)
    if index == arr.length
      arr << 0
    elsif arr[index] < 61
      arr[index] += 1
      arr
    else #(arr[index] == 61)
      arr[index] = 0
      arr = increment(arr, index + 1)
    end
  end

  def map_ints_to_chars(int_arr)
    chars_arr = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
      'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B',
      'C','D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q',
      'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0','1', '2', '3', '4', '5',
      '6', '7', '8', '9']

    int_arr.map {|i| chars_arr[i] }.join
  end

  def map_url_iteration_from_redis_to_int_array
    $redis.lrange("url_iteration", 0, -1).map{|s| s.to_i }
  end

  def frequency(short_url)
    $redis.hget("frequency", short_url).to_i
  end

  def minimum_frequency
    $redis.get("minimum_frequency").to_i
  end

  def update_frequency(short_url)
    #This will also insert, if the key does not yet exist
    $redis.hincrby("frequency", short_url, 1)
  end

  def add_to_top_100(short_url)
    #add to sorted set, with frequency being the score, and short_url the member
    $redis.zadd("top_100", frequency(short_url), short_url)
  end

  def valid_top_100?(short_url)
    $redis.zcard("top_100") < 100 || frequency(short_url) >= minimum_frequency
  end

  def get_top_100
    $redis.zrevrangebyscore("top_100", "+inf", "-inf", :with_scores => true)
  end

  def parse_top_100    
    get_top_100.map do |ar|
      short_url = ar[0]
      frequency = ar[1]
      full_url = $redis.hget("short_keys", short_url)
      {"short_url": short_url, "frequency": frequency, "full_url": full_url}
    end
  end

  def prune_top_100
    if $redis.zcard("top_100") > 100
      sorted_members = get_top_100
      #Because we prune every time, we will only ever need to remove one member
      lowest_score_member = sorted_members[-1][0]
      $redis.zrem("top_100", lowest_score_member)
      new_minimum_score = sorted_members[-2][1]
      update_minimum_frequency(new_minimum_score)
    end
  end

  def update_minimum_frequency(score)
    $redis.set("minimum_frequency", score)
  end

end