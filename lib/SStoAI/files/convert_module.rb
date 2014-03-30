# -*- encoding: utf-8 -*-
require 'natto'

module StorytoData

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
    unless str == nil
      if str.include?("「")
        return str[0..str.rindex("「")-1]
      else
        return "exception"
      end
    else
      return "exception"
    end
  end

  def sstoHash(name)
    s = File.read("./libs/saved.txt", :encoding => Encoding::UTF_8)
    s.gsub!("｢","「")
    s.gsub!("『","「")
    s.gsub!("｣","」")
    s.gsub!("』","」")
    s = s.split("\n")

    statements = s.select do |segment|
      segment.include?("「") and segment.include?("」")
    end

    p statements
    inReplyto = Hash::new
    s_clone = statements
    statements.each_with_index do |stat,l|
      whoisnext = whoIsTalking(s_clone[l+1])
      if whoIsTalking(stat) == name and whoIsTalking(s_clone[l+1]) != name
        inReplyto.store(extractSerif(stat),extractSerif(s_clone[l+1]))
      end
    end
    return inReplyto
  end

end
