# Shortr

Shortr is a small Sinatra app that magically turns your own domain into a url shortening service!  It provides the following HTTP resources:

This allows you to obtain the next shortcode for a url:

    GET /shortr?url=http://someurl.com
    => 302 /@@0?redirect=false
    
This redirects users to the full url given a shortcode:

    GET /@@0
    => 302 http://someurl.com
    
This gives you the number of clicks for a given shortcode:

    GET /@@0/clicks
    => 200 1
    
Shortr uses Redis, Sinatra, and Unicorn to do it's magic.  Here is how to get up and running on Ubuntu:

    sudo apt-get install redis
    sudo gem install sinatra redis unicorn
    unicorn -c unicorn.rb -E production -D -l localhost:4568
    
If you use Nginx, the following configuration will work nicely:

    upstream shortr_server {
      server unix:/var/www/shortr/unicorn.sock
      fail_timeout=0;
    }
    
    server {
      listen 80;
      root /var/www/vanpelt;
      server_name .vanpe.lt;
      access_log /var/log/nginx/vanpelt.access_log main;
      error_log /var/log/nginx/vanpelt.error_log info;

      location / {

        if (-f $request_filename) {
          break;
        }

        if (-f $request_filename/index.html) {
          rewrite (.*) $1/index.html break;
        }

        if (-f $request_filename.html) {
          rewrite (.*) $1.html break;
        }

        if (!-f $request_filename) {
          proxy_pass http://shortr_server;
          break;
        }
      }
    }
    