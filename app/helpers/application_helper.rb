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

  def check_frequency(short_url)
    $redis.hget("frequency", short_url)
  end

  def update_frequency(short_url)
    $redis.hincrby("frequency", short_url, 1)
  end


end