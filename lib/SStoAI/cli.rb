# coding: utf-8
[
'thor',
'SStoAI',
'fileutils',
'bundler/setup',
'nokogiri',
'open-uri',
'uri',
'natto',
'extractcontent'
].each do |str|
  require str
end

module SStoAI
  class CLI < Thor

    desc "test WORD", "testing."
    def test(word)
      say word
    end

    desc "new projectharuka 春香" , "Creaate the new AI."
    option :autocollection
    def new(word,name)
      projectDirectory = "#{Dir.home}/#{word}"
      @name = name
      unless FileTest.exist?(projectDirectory)

        [projectDirectory, projectDirectory+"/libs"].each do |dirname|
          FileUtils.mkdir(dirname)
          puts "create #{dirname}"
        end
        ['Gemfile', 'cli.rb'].each do |filename|
          FileUtils.copy("./lib/SStoAI/files/#{filename}", projectDirectory)
        end
        ['talk', 'bot', 'key', 'AU', 'convert_module'].each do |filename|
          FileUtils.copy("./lib/SStoAI/files/#{filename}.rb", "#{projectDirectory}/libs")
        end
        ['ss', 'data', 'saved'].each do |filename|
          FileUtils.copy("./lib/SStoAI/files/#{filename}.txt", "#{projectDirectory}/libs")
        end
        if options[:autocollection]
          matomes = []
          for num in 1..3 do
            matomes.push(URI.escape("http://ssmatomeantenna.info/search.html?category=#{name}&pageID=#{num}"))
          end
          File.open("#{projectDirectory}/libs/ss.txt","a") do |file|
            matomes.each do |matome|
              extractURLs(matome).each do |url|
                next if url.include?("2chmoeaitemu")
                puts "saving ss from #{url}"
                extractBody(url).each do |str|
                  file.write("#{str}\n")
                end
              end
            end
          end
          study(name, projectDirectory)
        end
        puts "complete!"

      else
        puts "もうそのディレクトリあるからｗバーカｗ"
      end
    end

    private

    def extractBody(url)
      open(url) do |io|
        html = io.read
        body, title = ExtractContent.analyse(html)
        strs = []
        body.split("  ").each do |str|
          strs.push(str) if str.include?("「") and !isNamespace(str)
        end
        return strs
      end
    end

    def isNamespace(str)
      if str.length >= 54
        namespace = str[0..54]
        return (namespace.include?(":") and namespace.include?("/"))
      else
        return false
      end
    end

    def extractURLs(url)
      page = URI.parse(url).read
      charset = page.charset
      html = (Nokogiri::HTML(page, url, charset))
      urls = []
      html.css('a').each do |str|
        str = str.to_s.encode("UTF-8","UTF-8")
        urls.push(str.split('"')[1]) if str.include?("「") and !str.include?("amazon")
      end
      return urls
    end

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
      s_clone = statements
      statements.each_with_index do |stat,l|
        whoisnext = whoIsTalking(s_clone[l+1])
        if whoIsTalking(stat) == name and whoIsTalking(s_clone[l+1]) != name
          inReplyto.store(extractSerif(stat),extractSerif(s_clone[l+1]))
        end
      end
      return inReplyto
    end

    def study(charactername,projectDirectory)
      s = File.read("#{projectDirectory}/libs/ss.txt", :encoding => Encoding::UTF_8)
      converted =[]
      s.split("\n").each do |segment|
        converted.push(segment) if segment.include?("「") and segment.include?("」")
      end
      File.open("#{projectDirectory}/libs/saved.txt","a") do |file|
        converted.each do |s|
          file.write("#{s}\n")
        end
      end
      sstoHash("#{projectDirectory}/libs/saved.txt", @name).each do |hash|
        File.open("#{projectDirectory}/libs/data.txt", "a") do |file|
          file.write "#{hash[0]}||#{extractNouns(hash[1]).join(",")}\n"
        end
      end
    end

  end
end
