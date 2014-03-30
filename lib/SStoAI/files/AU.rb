# -*- encoding: utf-8 -*-
require 'natto'

class AU

  def initialize
    data = File.read("./data.txt", :encoding => Encoding::UTF_8).split("\n")
    @targets = []
    @responses = []
    data.each_with_index do |variable,l|
      variable = variable.split("||")
      @targets[l] = variable[1]
      @responses[l] = variable[0]
    end
  end

  def respond(str)
    input = extractNounsforTalking(str)
    result = []
    hitnumbers = []
    texts=[]
    input.each do |input|

      @targets.each_with_index do |nouns,number|
        if nouns != nil
          if nouns.include?(input)
            result.push(nouns)
            hitnumbers.push(number)
          end
        end
      end

      n = 0
      n = hitnumbers.sample.to_i unless hitnumbers.length == 0
      texts.push(@responses[n]) if n != 0
    end
    if text.length != 0
      return texts.sample
    else
      return nil
    end
  end

  private

  def extractNounsforTalking(str)
    nm = Natto::MeCab.new
    nouns = []
    nm.parse(str) do |n|
      nouns.push(n.surface)
    end
    data = []
    nouns_clone=nouns
    nouns.each_with_index do |noun,l|
      data.push("#{nouns_clone[l-1]}#{noun}")
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

end
