# -*- encoding: utf-8 -*-
require 'natto'
require 'tweetstream' #これがないとなぜか動かない
require 'twitter'
require './key.rb'
require './malkov.rb'


Twitter.configure do |config|
   config.consumer_key        = Const::CONSUMER_KEY
   config.consumer_secret     = Const::CONSUMER_SECRET
   config.oauth_token            = Const::ACCESS_TOKEN
   config.oauth_token_secret  = Const::ACCESS_TOKEN_SECRET
end
TweetStream.configure do |config|
   config.consumer_key        = Const::CONSUMER_KEY
   config.consumer_secret     = Const::CONSUMER_SECRET
   config.oauth_token            = Const::ACCESS_TOKEN
   config.oauth_token_secret  = Const::ACCESS_TOKEN_SECRET
   config.auth_method            = :oauth
end

def readdata
  s = File.read("data.txt", :encoding => Encoding::UTF_8)
  s = s.split("\n")
  stat = []
  s.each do |s|
    stat.push(s.split("||")[0])
  end
  return stat
end

natto = Natto::MeCab.new

m = Malkov.new(readdata,natto)

Twitter.update m.create
