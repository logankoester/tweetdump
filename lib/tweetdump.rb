#!/usr/bin/env ruby
require 'logger'
require 'rubygems'
require 'eventmachine'
require 'tweetstream'
require 'hashie'
require 'twitter'
require 'json'

class TweetDump
  attr_accessor :screen_name, :password, :keyword, :logfile, :limit, :api
  def initialize(opts={})
    @screen_name = opts[:screen_name]
    @password = opts[:password]
    @limit = opts[:limit]
    @logfile = opts[:logfile] || '/dev/null'
    @api = opts[:api] || 'streaming'
    @keyword = opts[:keyword]
  end

  def run!
    @count = 1
    @page = 0
    if @api == 'streaming'
      fetch_streaming
    elsif @api == 'search'
      fetch_search
    else
      logger.error "API is invalid or unsupported"
      raise "Unsupported API"
    end
  end

private
  def fetch_streaming
    logger.info "Connecting to Twitter..."
    EventMachine::run {
      stream = Twitter::JSONStream.connect(
        :path    => '/1/statuses/filter.json',
        :auth    => "#{@screen_name}:#{@password}",
        :content => "track=#{@keyword}",
        :method => 'POST'
      )

      stream.each_item do |status|
        begin
          puts status
          tweet = Hashie::Mash.new(JSON.parse(status))          
          logger.info "Fetched tweet ##{tweet.id} via Streaming API"
          logger.info "Job Status: #{@count}/#{@limit}"
          if @limit and @count >= @limit
            logger.info "Limit reached (#{@count} out of #{@limit})"
            logger.info "Disconnecting from Twitter"
            return
          else
            @count += 1
          end
        rescue Exception => e
          logger.error e
        end
      end
      
      stream.on_error do |message|
        # No need to worry here. It might be an issue with Twitter. 
        # Log message for future reference. JSONStream will try to reconnect after a timeout.
        logger.error message
        puts message
        logger.info "Disconnecting from Twitter"
        return
      end

      stream.on_max_reconnects do |timeout, retries|
        # Something is wrong on your side.
        msg = "Hit max reconnects to Twitter: timeout=#{timeout}, retries=#{retries}"
        logger.error msg
        puts msg 
        return
      end
    }
  end

  # Note that due to programmer laziness tweets from the Search API are parsed into a Ruby
  # object and then dumped back to JSON again.
  def fetch_search
    tweets = Twitter::Search.new(@keyword, :page => @page).fetch
    tweets.results.each do |tweet|
      puts JSON.dump(tweet)
      logger.info "Fetched tweet ##{tweet.id} via Search API"
      logger.info "Job Status: #{@count}/#{@limit}"
      if @limit and @count >= @limit
        logger.info "Limit reached (#{@count} out of #{@limit})"
        return
      else
        @count += 1
      end
    end
    @page += 1
    fetch_search
  end

  def logger
    @@logger ||= Logger.new(logfile)
  end
end
