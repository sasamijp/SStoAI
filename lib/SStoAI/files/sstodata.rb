# -*- encoding: utf-8 -*-
require 'natto'

module storytoData

  def extractNouns(str)
    nm = Natto::MeCab.new
    nouns = []
    nm.parse(str) do |n|
      nouns.push(n.surface)
    end
    data = []
    nouns_clone = nouns
    nouns.each_with_index do |noun,l|
      data.push("#{nouns_clone[l-1]}#{noun}")
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

  def extractSerif(str)
    if str.include?("「")
      name = str[0..str.rindex("「")-1]
      str.sub!("「","")
      str.sub!("」","")
      str.sub!("#{name}","")
    end
    return str
  end

  def whoIsTalking(str)
    if str.include?("「")
      return str[0..str.rindex("「")-1]
    else
      return "exception"
    end
  end

  def saveSS
    s = File.read("./data/ss.txt", :encoding => Encoding::UTF_8)
    converted =[]
    s.split("\n").each do |segment|
      converted.push(segment) if segment.include?("「") and segment.include?("」")
    end
    File.open("./data/saved.txt","a") do |file|
      converted.each do |s|
        file.write("#{s}\n")
      end
    end
  end

  def study(charactername)
    sstoHash("./data/saved.txt", charactername).each do |hash|
      File.open("./data/data.txt", "a") do |file|
        file.write "#{hash[0]}||#{extractNouns(hash[1]).join(",")}\n"
      end
    end
  end

end
