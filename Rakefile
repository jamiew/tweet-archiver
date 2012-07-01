require 'rubygems'

require 'pp'
require 'fileutils'
require 'yaml'
require 'to_openstruct'

require 'bundler'
Bundler.setup
require 'json'
require 'twitter'
require 'twitter/json_stream'
require 'phantomjs.rb'
require 'screencap'
require 'imgur2'


# Configure
$config = YAML.load(File.open('config.yml').read)
$config ||= JSON.parse(ENV['TWEET_ARCHIVE_CONFIG']) # pushing all local settings to prod in one big blob; TODO add rake task for that
pp $config

Twitter.configure do |config|
  tc = $config['twitter']
  ['consumer_key', 'consumer_secret', 'oauth_token', 'oauth_token_secret'].each do |field|
    raise "Error, config['twitter']['#{field}'] key missing. Please edit config.yml" if tc[field].nil? || tc[field].empty?
  end

  config.consumer_key = tc['consumer_key']
  config.consumer_secret = tc['consumer_secret']
  config.oauth_token = tc['oauth_token']
  config.oauth_token_secret = tc['oauth_token_secret']
end


# Helpers
def handle_tweet(status)
  tweet = status.to_openstruct
  if tweet.nil?
    STDERR.puts "Bad tweet man"; STDERR.flush
    return
  elsif tweet.text.empty?
    STDERR.puts "Blank tweet text, skipping"; STDERR.flush
    return
  end

  # Build the url to the tweet
  # why isn't this in the status obj? Weird
  user_url = "http://twitter.com/#{tweet.user.screen_name}"
  tweet_url = "#{user_url}/status/#{tweet.id_str}"
  STDOUT.puts "Tweetscan: received \"#{tweet.user.screen_name}: #{tweet.text}\" => #{tweet_url}"
  STDOUT.flush

  if true # it's new
    # Save it to disk
    puts "Saving tweet to disk..."; STDOUT.flush
    json_file = "tweets/#{tweet.user.screen_name}-#{tweet.id_str}.json"
    File.open(json_file, 'w') {|f| f.write(status.to_json) }

    # Post it back to Twitter (?)
    # ...

    # Take a screenshot -- just the fullscreen one pls
    puts "Capturing screenshot..."; STDOUT.flush
    output = "screenshots/#{tweet.user.screen_name}-#{tweet.id_str}"
    screenshot_file = "#{output}-full.png" # what webkit2png actually makes (using -F)

    f = Screencap::Fetcher.new(tweet_url)
    # screenshot = f.fetch(:div => '.header', :output => '~/screenshot_file.png') #dont forget the extension!
    screenshot = f.fetch(:output => screenshot_file) #dont forget the extension!

    # screenshotter = EventMachine::DeferrableChildProcess.open("webkit2png #{tweet_url} -F -o #{output}")
    #
    # screenshotter.callback {|data|
      data ||= nil
      puts "Screenshot captured. #{data.inspect}"
      # Upload said image to imgur
      if $config['imgur']
        puts "Uploading to imgur..."; STDOUT.flush
        imgur = Imgur2.new($config['imgur']['api_key'])
        upload = imgur.upload( File.open(screenshot_file) )
        pp upload; STDOUT.flush

        # Tweet that we posted to imgur (!)
        imgur_page = upload['upload']['links']['imgur_page']
        if imgur_page
          puts "Posting imgur page to Twitter => #{imgur_page}"
          twitter = Twitter.update(upload['upload']['links']['imgur_page'])
        end
      else
        puts "No imgur credentials, not uploading"; STDOUT.flush
      end

      # Upload that shit to S3 ...
      # TODO
      puts "Screenshot post-processing done."; STDOUT.flush
    # }
    # screenshotter.errback {|data|
    #   STDERR.puts "Error taking screenshot!"; STDERR.flush
    # }

  end

  tweet
end


# void main()
task :tweetscan do

  $stdout.puts "Tweetscan launching..."; $stdout.flush

  # Make our directory for screenshots and saving tweets
  FileUtils.mkdir_p 'tweets'
  FileUtils.mkdir_p 'screenshots'

  # Run our query
  raise "No query key specified in config" if $config['query'].nil? || $config['query'].empty?

  search_query = $config['query']
  path = "/1/statuses/filter.json?#{search_query}"
  $stdout.puts "path=#{path.inspect}"; $stdout.flush

  EventMachine::run {
    stream = Twitter::JSONStream.connect(
      :path    => path,
      :oauth => {
        :consumer_key    => ENV['CONSUMER_KEY'] || Twitter.consumer_key,
        :consumer_secret => ENV['CONSUMER_SECRET'] || Twitter.consumer_secret,
        :access_key      => ENV['ACCESS_KEY'] || Twitter.oauth_token,
        :access_secret   => ENV['ACCESS_SECRET'] || Twitter.oauth_token_secret,
      },
      :ssl => true
    )

    stream.each_item do |item|
      json = JSON.parse(item)
      handle_tweet(json)
    end

    stream.on_error do |message|
      $stdout.print "Tweetscan error: #{message}\n"
      $stdout.flush
    end

    stream.on_reconnect do |timeout, retries|
      $stdout.print "Tweetscan reconnecting in: #{timeout} seconds\n"
      $stdout.flush
    end

    stream.on_max_reconnects do |timeout, retries|
      $stdout.print "Tweetscan failed after #{retries} failed reconnects\n"
      $stdout.flush
    end

    trap('TERM') {
      stream.stop
      EventMachine.stop if EventMachine.reactor_running?
    }
  }
end

