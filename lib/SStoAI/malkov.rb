# -*- encoding: utf-8 -*-

class Malkov

  def initialize(directory, natto)
    
    array = readdata("./#{directory}/data.txt")
    @directory = directory
    @dictionary = []
    @natto = natto
    @firsts = []

    array.flatten.each do |segment|
      words = wakati(natto,segment,'surface').compact
      splitnums = []

      words.each_with_index do |word,l|
        case wakati(natto,word,'part')[0]
        when "名詞"
          splitnums.push(l) if rand(2) == 1
        end
      end

      splitnums.each do |num|
        @firsts.push("#{segment.split(words[num])[0]}&&#{words[num]}")
        str = words[num]
        for l in 1..20 do
          str << "&&#{words[num+l]}"
          str << "__END__" if l == 20
          break if splitnums.index(num+l) != nil
        end
        @dictionary.push(str)
      end
    end
  end

  def create
    text = [@firsts.sample]

    loop do
      nextword = @dictionary.compact.sample
      for l in 1..20 do
        text.push(nextword.split("&&")[l])
      end
      break if nextword.include?("__END__")
      text.compact!
    end

    return text.join("").gsub(/__END__|&&| /,"")
  end

  def name
    return File.read("./#{@directory}/name.txt", :encoding => Encoding::UTF_8)
  end

  private

  def readdata(filename)
    s = File.read(filename, :encoding => Encoding::UTF_8)
    s = s.split("\n")
    stat = []
    s.each do |s|
      next unless s.include?("||")
      stat.push(s.split("||")[0])
    end
    return stat
  end

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

  def splitable?(str1,str2)
    return (str1.include?("&&") and str2.include?("&&"))
  end

end
