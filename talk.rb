# -*- encoding: utf-8 -*-
require 'natto'

def readdata
  s = File.read("data.txt", :encoding => Encoding::UTF_8)
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
  nouns_clone=nouns.reverse.push("")
  nouns_clone.reverse! #フラッペ
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

puts 'Type "exit" to exit'
loop do
  input = gets.chomp
  break if input == "exit"
  input = extractNouns(input)

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
  p texts.sample
end
