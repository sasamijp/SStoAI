# -*- encoding: utf-8 -*-

class Malkov

  def initialize(*str,natto)
    array = str
    statements = []
    @natto = natto
    @firsts = []
    
    array.flatten.each do |segment|

      
      words = wakati(natto,segment,'surface').compact
      splitnums = []

      words.each_with_index do |word,l|
        case wakati(natto,word,'part')[0]
        when '名詞', '助詞'
          splitnums.push(l)
        end
      end


      splitnums.each do |num|

        @firsts.push("#{segment.split(words[num])[0]}&&#{words[num]}")


        statements.push("#{words[num]}&&#{segment.split(words[num])[1]}")

      end

    end
    p statements
    @dictionary = statements

  end


  def create
    @text = [@firsts.sample]
    loop do

      nextwords = @dictionary.compact.select do |item|
        (splitable?(item) and splitable?(@text[@text.length-1]) and @text[@text.length-1].split("&&")[1] == item.split("&&")[0])
      end

      case nextwords.length
      when 0
        break
      else

        @text.push(nextwords.compact.sample.split("&&")[1])
      end
      @text.compact!
    end
    return @text.join("").gsub("&&","").gsub(" ","")
  end


  private

  def wakati(natto,str,mode)

    surfaces = []
    parts = []
    natto.parse(str) do |n|
      surfaces.push(n.surface)
      parts.push(n.feature.split(",")[0])
    end

    case mode
    when "surface"
      return surfaces
    when "part"
      return parts
    end

  end

  def splitable?(str)
    return (str.include?("&&"))
  end


end
