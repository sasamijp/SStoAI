# -*- encoding: utf-8 -*-
require 'natto'
require 'tweetstream' #これがないとなぜか動かない
require 'twitter'
require './key.rb'


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


class Malkov

  def initialize(*str)
    @array = str
    @array.flatten!
    @nm = Natto::MeCab.new
  
    statements = []
    @array.each do |segments|

      statement = segments

      @nm.parse(segments) do |n|
        type = n.feature.split(",")[0]
        if type == "名詞"
          statements.push("#{statement.split(n.surface)[0]} #{n.surface}")
          statements.push("#{n.surface} #{statement.split(n.surface)[1]}")
        end
      end

    end

    @dictionary = statements
  end

  def create

    text = []
    first = @dictionary.sample
    text.push(first)

    5.times do
      nextwords = @dictionary.select do |item|
        (item.split[0] == text[text.length-1].split[1])
      end

    
      nextwords.delete_if do |word|
        text.to_s.include?(word)
      end
      unless nextwords == nil
        nextword = nextwords.compact.sample
        unless nextword == nil
          text.push(nextword.split[1])
        end  
      end
    end

    return text.join("").gsub(" ","")
  end

end

m = Malkov.new(readdata)

Twitter.update m.create
