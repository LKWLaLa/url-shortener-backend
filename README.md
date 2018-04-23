# Shrink Me

### Description:

A URL shortener backend, built with Sinatra and Redis. The corresponding client-side application is located [here.](https://github.com/LKWLaLa/url-shortener-fe)


### Dependencies:

- If not already available, install Ruby, [Bundler](http://bundler.io/), and [Redis](https://redis.io/topics/quickstart).


### Installation Guide:

Clone this repository, then cd into the directory on your local machine.  
Run:

```bash
bundle install
shotgun
```

The application should be active at localhost:9393 in your web browser.  

### Redis data structures:

If you are recreating the necessary redis data structures locally, I've structured my store in the following way:

  1. "short_keys" - hash with the structure {short_url : full_url}
  2. "long_keys" - hash with the structure {full_url : short_url}
  3. "frequency" - hash with the structure {short_url : number of hits}
  4. "top_100" - sorted set, where the member is the short_url and the score is the frequency (number of hits)
  5. "minimum_frequency" - a simple key, value pair that holds a counter of the lowest score / frequency value in the "top_100" sorted set.  

### Live Site:

The deployed backend is located [here.](https://shrink-me.herokuapp.com/)

