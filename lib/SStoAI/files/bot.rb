# -*- encoding: utf-8 -*-
require 'natto'
require 'tweetstream'
require 'twitter'
require './key.rb'


rest = Twitter::REST::Client.new do |config|
  config.consumer_key        = Const::CONSUMER_KEY
  config.consumer_secret     = Const::CONSUMER_SECRET
  config.access_token        = Const::ACCESS_TOKEN
  config.access_token_secret = Const::ACCESS_TOKEN_SECRET
end
TweetStream.configure do |config|
   config.consumer_key        = Const::CONSUMER_KEY
   config.consumer_secret     = Const::CONSUMER_SECRET
   config.oauth_token            = Const::ACCESS_TOKEN
   config.oauth_token_secret  = Const::ACCESS_TOKEN_SECRET
   config.auth_method            = :oauth
end

client = TweetStream::Client.new

def readdata
  s = File.read("./data.txt", :encoding => Encoding::UTF_8)
  s = s.split("\n")
  return s
end

s = readdata()
dictionary = []
dictionary2 = []

s.each_with_index do |variable,l|
  variable = variable.split("||")
  dictionary[l] = variable[1]
  dictionary2[l] = variable[0]
end

def extractNouns(str)
  nm = Natto::MeCab.new
  nouns = []
  nm.parse(str) do |n|
    nouns.push(n.surface)
  end
  data = []
  nouns_clone = nouns.reverse.push("").reverse!
  nouns.each_with_index do |noun,l|
    data.push("#{nouns_clone[l]}#{noun}")
  end
  result = []
  data.each do |dat|
    isInclude = false
    nm.parse(dat) do |n|
      type = n.feature.split(",")[0]
      case type
      when "名詞","動詞","記号","形容詞"
        isInclude = true
      end
    end
    result.push(dat) if isInclude
  end
  return result
end

def isReply(str,name,id)
  if str.include?("@#{id}") and !str.include?("RT") and name != "#{id}"
    return true
  else
    return false
  end
end

screen_name = Const::SCREEN_NAME

client.userstream do |status|
  p status.text
  if isReply(status.text,status.user.screen_name,screen_name)

    input = extractNouns(status.text.gsub("@sa2mi ",""))

    result = []
    hitnumbers = []
    texts=[]
    input.each do |input|
      dictionary.each_with_index do |nouns,number|
        n = 0
        if nouns != nil
          if nouns.include?(input)
            result.push(nouns)
            hitnumbers.push(number)
          end
        end
      end

      n = hitnumbers.sample.to_i
      texts.push(dictionary2[n]) if n != 0

    end
    p texts
    text = texts.sample
    text = "@#{status.user.screen_name} #{text}"
    option = {"in_reply_to_status_id"=>status.id.to_s}
    rest.update text,option

  end
end
