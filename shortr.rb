require 'rubygems'
require 'sinatra'
require 'redis'

class Shortr < Sinatra::Base
  set :raise_errors, false
  set :show_exceptions, false
  set :dump_errors, false
  
  get "/shortr" do
    shortned = Shortr.save(params[:url])
    shortned ? redirect("/#{shortned}?redirect=false") : 404
  end

  get "/:shortned" do
    url = Shortr.url(params[:shortned])    
    url && !params[:redirect] ? redirect(url) : 404
  end

  get "/:shortned/clicks" do
    clicks = Shortr.clicks(params[:shortned])
    clicks ? clicks : 404
  end
  
  def self.redis
    @@redis ||= Redis.new
  end
  
  def self.key(*args)
    (["shortr"] + args).join(":")
  end
  
  def self.links
    redis.get(key("links")).to_i
  end
  
  def self.clicks(shortned)
    redis.get(key(shortned, "clicks"))
  end
  
  def self.url(shortned)
    url = redis.get(key(shortned))
    redis.incr(key(shortned, "clicks")) if url
    url
  end
  
  def self.save(url)
    return false unless url
    short = shortned
    redis.set(key(short), url)
    redis.incr(key("links"))
    short
  end
  
  def self.shortned
    ("%3s" % Shortr.links.to_s(36)).gsub(/ /, "@")
  end
end