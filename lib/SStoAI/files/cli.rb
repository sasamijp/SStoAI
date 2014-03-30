# -*- encoding: utf-8 -*-
require 'thor'
require './libs/convert_module'
require './libs/AU'

class BOTCLI < Thor

  desc "hello NAME", "say hello to NAME"
  def hello(name)
    puts "Hello #{name}"
  end

  desc "convert 春香","SS to AI from ./libs/ss.txt"
  def convert(charname)
    include StorytoData
    s = File.read("./libs/ss.txt", :encoding => Encoding::UTF_8)
    converted =[]

    s.split("\n").each do |segment|
      converted.push(segment) if segment.include?("「") and segment.include?("」")
    end

    File.open("./libs/saved.txt","a") do |file|
      converted.each do |s|
        file.write("#{s}\n")
      end
    end

    File.open("./libs/data.txt", "a") do |file|
      sstoHash(charname).each do |hash|
        file.write "#{hash[0]}||#{extractNouns(hash[1]).join(",")}\n"
      end
    end

  end

  desc "talk sentence","talk to AI"
  def talk(str)
    au = AU.new()
    puts au.respond(str)
  end

  desc 'twitterbot', 'take off'
  def twitterbot()
    require './libs/key.rb'
    if (Const::CONSUMER_KEY == "") or (Const::CONSUMER_SECRET == "") or (Const::ACCESS_TOKEN == "") or (Const::ACCESS_TOKEN_SECRET == "") or (Const::SCREEN_NAME == "")
      puts "Please set your keys at ./libs/key.rb"
    else

      ['twitter','tweetstream'].each do |lib|
        require lib
      end

      configure_rest = Thread.new do
        rest = Twitter::REST::Client.new do |config|
          config.consumer_key        = Const::CONSUMER_KEY
          config.consumer_secret     = Const::CONSUMER_SECRET
          config.access_token        = Const::ACCESS_TOKEN
          config.access_token_secret = Const::ACCESS_TOKEN_SECRET
        end
      end
      configure_stream = Thread.new do
        TweetStream.configure do |config|
          config.consumer_key        = Const::CONSUMER_KEY
          config.consumer_secret     = Const::CONSUMER_SECRET
          config.oauth_token            = Const::ACCESS_TOKEN
          config.oauth_token_secret  = Const::ACCESS_TOKEN_SECRET
          config.auth_method            = :oauth
        end
      end
      configure_AU = Thread.new do
        au = AU.new()
      end

      [configure_rest, configure_stream, configure_AU].each do |thread|
        thread.join
      end
      puts "configure complete!"

      client = TweetStream::Client.new
      client.userstream do |status|
        print "."
        if status.text.include?("@#{Const::SCREEN_NAME}")
          puts "received reply from #{status.user.screen_name}"
          tweet = "@#{status.user.screen_name} #{au.respond(status.text.gsub("@#{Const::SCREEN_NAME}","")}"
          option = {"in_reply_to_status_id"=>status.id.to_s}
          rest.update(tweet, option)
        end
      end

    end
  end

end

BOTCLI.start(ARGV)
