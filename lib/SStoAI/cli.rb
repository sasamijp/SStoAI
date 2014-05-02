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
'extractcontent',
'./lib/SStoAI/AU.rb',
'./lib/SStoAI/malkov.rb'
].each do |str|
  require str
end

module SStoAI
  
  class CLI < Thor

    desc "test WORD", "testing."
    def test(word)
      say word
    end

    desc "new dirname 名前" , "Create the new AI."
    def new(word, name)
      projectDirectory = "./#{word}"

      unless FileTest.exist?(projectDirectory)

        [projectDirectory].each do |dirname|
          FileUtils.mkdir(dirname)
          puts "create #{dirname}"
        end
        ['key'].each do |filename|
          FileUtils.copy("./lib/SStoAI/files/#{filename}.rb", projectDirectory)
        end
        ['ss', 'data', 'saved', 'name'].each do |filename|
          FileUtils.copy("./lib/SStoAI/files/#{filename}.txt", projectDirectory)
        end

        File.open("#{projectDirectory}/ss.txt","a") do |file|
          collectmatomeURLs(name, 3).each do |matome|
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

        File.open("#{projectDirectory}/name.txt","a") do |file|
          file.write(name)
        end

        puts "complete!"

      else

        puts "もうそのディレクトリあるからｗバーカｗ"

      end
    end

    desc "reconvert name 名前","SS to AI from /ss.txt"
    def reconvert(directory, charname)

      projectDirectory = "./#{directory}"

      s = File.read("#{projectDirectory}/ss.txt", :encoding => Encoding::UTF_8)

      converted =[]
      s.split("\n").each do |segment|
        converted.push(segment) if segment.include?("「") and segment.include?("」")
      end

      File.open("#{projectDirectory}/saved.txt","a") do |file|
        converted.each do |s|
          file.write("#{s}\n")
        end
      end

      File.open("#{projectDirectory}/data.txt", "a") do |file|
        sstoHash("#{projectDirectory}/saved.txt", charname).each do |hash|
          response = hash[0]
          targets = extractNouns(hash[1])
          next if targets == nil
          file.write "#{response}||#{targets.join(",")}\n"
        end
      end

      puts "complete!"

    end

    desc "talk directoryname 文章","talk to AI"
    def talk(name, str)
      au = AU.new(name)
      puts au.respond(str)
    end

    desc 'twitterbot directoryname', 'take off'
    def twitterbot(name)

      require "./#{name}/key.rb"
      if (Const::CONSUMER_KEY == "") or (Const::CONSUMER_SECRET == "") or (Const::ACCESS_TOKEN == "") or (Const::ACCESS_TOKEN_SECRET == "") or (Const::SCREEN_NAME == "")
        puts "Please set your keys at /key.rb"
      else

        require 'twitter'
        require 'tweetstream'

        configure_tw = Thread.new do
          @rest = Twitter::REST::Client.new do |config|
            config.consumer_key        = Const::CONSUMER_KEY
            config.consumer_secret     = Const::CONSUMER_SECRET
            config.access_token        = Const::ACCESS_TOKEN
            config.access_token_secret = Const::ACCESS_TOKEN_SECRET
          end
          TweetStream.configure do |config|
            config.consumer_key        = Const::CONSUMER_KEY
            config.consumer_secret     = Const::CONSUMER_SECRET
            config.oauth_token         = Const::ACCESS_TOKEN
            config.oauth_token_secret  = Const::ACCESS_TOKEN_SECRET
            config.auth_method            = :oauth
          end
        end

        configure_AU = Thread.new do
          @au = AU.new(name)
        end

        [configure_tw, configure_AU].each do |thread|
          thread.join
        end
        puts "configure complete!"

        client = TweetStream::Client.new
        client.userstream do |status|
          print "."
          if !status.text.start_with?("RT") and status.text.include?("@#{Const::SCREEN_NAME}")
            puts "received reply from #{status.user.screen_name}"
            @au = AU.new(name)
            response = @au.respond(status.text.gsub("@#{Const::SCREEN_NAME} ",""))
            p response
            tweet = "@#{status.user.screen_name} #{response}"
            option = {"in_reply_to_status_id"=>status.id.to_s}
            p tweet
            @rest.update(tweet, option)
          end
        end

      end
    end

    desc 'generateSS filename 1000 tarou jirou ...', 'generate SS'
    def generateSS(filename, size, *actor)
      actors = actor
      p actors
      aus = []
      malkovs = []
      natto = Natto::MeCab.new
      actors.each do |actor|
        aus.push AU.new(actor)
        malkovs.push Malkov.new(actor ,natto)
      end

      File.open(filename, "w") do |file|

        starter = malkovs.sample
        response = starter.create
        file.write "#{starter.name}「#{response}」\n"

        for l in 0..size.to_i/actors.length do

          aus.each do |au|
            response = au.respond(response)
            file.write "#{au.name}「#{response}」\n"
          end

          if response == nil
            starter = malkovs.sample
            response = starter.create
            file.write "#{starter.name}「#{response}」\n"
          end

        end

      end

    end

    private

    def collectmatomeURLs(name, pagecount)
      matomes = []
      for num in 1..pagecount do
        matomes.push('http://ssmatomeantenna.info/search.html?category='+URI.escape("#{name}「")+'&pageID='+"#{num}")
      end
      return matomes
    end

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

    def extractSerif(str)
      return if str == nil
      if str.include?("「")
        name = str[0..str.rindex("「")-1]
        str.sub!("「","")
        str.sub!("」","")
        str.sub!("#{name}","")
      end
      return str
    end

    def whoIsTalking(str)
      return if str == nil
      if str.include?("「")
        return str[0..str.rindex("「")-1]
      else
        return
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

      inReplyto = Hash::new
      s_clone = statements
      statements.each_with_index do |stat,l|
        print '.'
        next if stat == "" or stat == nil
        if whoIsTalking(stat) == name and whoIsTalking(s_clone[l+1]) != name
          inReplyto.store(extractSerif(stat),extractSerif(s_clone[l+1]))
        end
      end
      return inReplyto
    end

    def study(name, projectDirectory)
      s = File.read("#{projectDirectory}/ss.txt", :encoding => Encoding::UTF_8)
      converted = []
      s.split("\n").each do |segment|
        converted.push(segment) if segment.include?("「") and segment.include?("」")
      end
      File.open("#{projectDirectory}/saved.txt","a") do |file|
        converted.each do |s|
          file.write("#{s}\n") unless s == nil
        end
      end
      sstoHash("#{projectDirectory}/saved.txt", name).each do |hash|
        File.open("#{projectDirectory}/data.txt", "a") do |file|
          response = hash[0]
          targets = extractNouns(hash[1])
          next if targets == nil
          file.write "#{response}||#{targets.join(",")}\n"
        end
      end
    end
    
  end
end
