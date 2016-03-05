#! /usr/bin/env ruby

require 'rss'
require 'open-uri'
require 'net/http'

# Argument verification
if ARGV.length != 2
  puts "Usage: #{$0} file.txt /directory/to/dump/torrents"
  puts "file example:"
  puts "anime name 1;1080;HorribleSubs"
  puts "anime name 2;720;HorribleSubs"
  exit 1
end

def main()
  #reading the file passed in parameter
  file = ARGV[0]
  if ! File.exist?("#{file}")
    puts "#{file} do not exist..."
    exit 1
  end
  file = File.new("#{file}", "r")

  # search the RSS feeds once for every line in the file
  while (line = file.gets)
      search_strings = line.split(";")
      search_strings[-1] = search_strings[-1].chomp
      search_rss(search_strings)
  end
end

def search_rss(search_strings)
  nyaa_rss_url = "http://www.nyaa.se/?page=rss"

  open(nyaa_rss_url) do |rss|
    feed = RSS::Parser.parse(rss)
    feed.items.each do |item|
      # Searching the item for every search_strings
      found = 0
      search_strings.each do |search_string|
        if item.title.match(/(#{search_string})/)
          found = found + 1
        end
      end

      # If we found every search terms download the torrent
      time1 = Time.new
      if found == search_strings.length
        download_torrent(item.link, item.title)
        f = File.open('nyaa.txt', 'a')

        old_out = $stdout
        $stdout = f

        puts "#{item.title}    " + time1.inspect

        f.close

        $stdout = old_out
        puts "Downloading #{item.title}."
      end
    end
  end
end

def download_torrent(link, torrent_name)
  path = ARGV[1]

  # Removing everything before www
  link = link.gsub!(/.*?(?=www)/im, "")

  # Downloading the torrent
  Net::HTTP.start("#{link.split('/', 2).first}") do |http|
    resp = http.get("/#{link.split('/', 2).last}")
    open("#{path}/#{torrent_name}.torrent", "wb") do |file|
      file.write(resp.body)
    end
  end
end

main()
