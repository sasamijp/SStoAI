# -*- encoding: utf-8 -*-
require 'natto'

def sstoHash(str,name)
  s = File.read(str, :encoding => Encoding::UTF_8)
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
  s_clone = statements.reverse.push("$")
  s_clone.reverse!        #フラッペ
  statements.each_with_index do |stat,l|
    whoisnext = whoIsTalking(s_clone[l])
    if whoIsTalking(stat) == "#{name}" and whoIsTalking(s_clone[l]) != "#{name}"
      inReplyto.store(extractSerif(stat),extractSerif(s_clone[l]))
    end
  end
  return inReplyto
end

def extractNouns(str)
  nm = Natto::MeCab.new
  nouns = []
  nm.parse(str) do |n|
    nouns.push(n.surface)
  end
  p nouns
  data = []
  nouns_clone = nouns.reverse.push("")
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
  s = File.read("ss.txt", :encoding => Encoding::UTF_8)
  converted =[]
  s.split("\n").each do |segment|
    converted.push(segment) if segment.include?("「") and segment.include?("」")
  end
  File.open("saved.txt","a") do |file|
    converted.each do |s|
      file.write("#{s}\n")
    end
  end
end

saveSS()
puts "complete!"
