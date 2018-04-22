require './config/environment'

module ApplicationHelper 

  def generate_short_url
    chars_arr = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
      'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B',
      'C','D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q',
      'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0','1', '2', '3', '4', '5',
      '6', '7', '8', '9']

      short_url = 7.times.map{ chars_arr.sample }.join
      $redis.hexists("short_keys", short_url) ? generate_short_url : short_url
  end

  def frequency(short_url)
    $redis.hget("frequency", short_url)
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
    $redis.zcard("top_100") < 100 || frequency(short_url) >= $redis.get("minimum_frequency")
  end

  def prune_top_100
    if $redis.zcard("top_100") > 100
      sorted_members = $redis.zrevrangebyscore("top_100", "+inf", "-inf", :with_scores => true)
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