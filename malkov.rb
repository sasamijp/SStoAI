# -*- encoding: utf-8 -*-

class Malkov

  def initialize(*str,natto)
    array = str
    statements = []

    array.flatten.each do |segment|

      natto.parse(segment) do |n|
        case n.feature.split(",")[0]
        when "助動詞", "名詞", "動詞", "形容詞", "助詞"
          statements.push("$$#{segment.split(n.surface)[0]} #{n.surface}")
          statements.push("#{n.surface} #{segment.split(n.surface)[1]}")
        end
      end

    end

    @dictionary = statements
  end

  def create
    
    firsts = @dictionary.select do |str|
      (str[0..1] == "$$") 
    end

    text = [firsts.sample]

    loop do

      nextwords = @dictionary.compact.select do |item|
        (item.include?(" ") and text.include?(" ") and item.split[0] == text[text.length-1].split[1])
      end

      case nextwords.length
      when 0 
        break
      else
        text.push(nextwords.compact.sample.split[1])
      end

    end

    return text.join("").gsub("$$","").gsub(" ","")

  end

end
