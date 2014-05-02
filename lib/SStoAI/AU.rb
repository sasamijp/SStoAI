# -*- encoding: utf-8 -*-
require 'natto'

class AU

  def initialize(directory)
    data = File.read("./#{directory}/data.txt", :encoding => Encoding::UTF_8).split("\n")
    @directory = directory
    @responsesandtargets = []
    data.each_with_index do |variable,l|
      next unless variable.include?("||")
      variable = variable.split("||")
      @responsesandtargets[l] = [variable[0],variable[1]]
    end
    @responsesandtargets.delete_if{ |value| value == nil or value[0] == nil or value[1] == nil }
  end

  def respond(str)
    input = extractKeyWords(str)
    return nil if input == nil

    @responsesandtargets.delete_if{ |value| wordsMatch(value[1].split(","), input) == 0 }
    @responsesandtargets.sort_by{ |value| wordsMatch(value[1].split(","), input) }
    @responsesandtargets.map!{ |value| value = value[0] }

    return biasHeadSample(@responsesandtargets)
  end

  def name
    return File.read("./#{@directory}/name.txt", :encoding => Encoding::UTF_8)
  end

  private

  def wordsMatch(words1, words2)
    match = 0
    words1.each do |word1|
      words2.each do |word2|
        match += 1 if word1 == word2
      end
    end
    return match.to_f/words1.length.to_f
  end

  def biasHeadSample(array)
    narray = []
    array.each_with_index do |value, l|
      (array.length-l)*(array.length-l).times do 
        narray.push value
      end
    end
    return narray.sample
  end

  def extractKeyWords(str)
    return nil if str == nil
    nm = Natto::MeCab.new
    nouns = []
    nm.parse(str) do |n|
      nouns.push(n.surface)
    end
    data = []
    nouns.each_with_index do |noun,l|
      next if l == 0
      break if l == nouns.length
      data.push("#{nouns[l-1]}#{noun}")
      data.push("#{noun}#{nouns[l+1]}")
    end
    result = []
    data.each do |dat|
      isInclude = false
      nm.parse(dat) do |n|
        type = n.feature.split(",")[0]
        case type
        when "名詞","動詞","形容詞"
          isInclude = true
        end
      end
      result.push(dat) if isInclude
    end
    return result
  end

end
