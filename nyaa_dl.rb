#! /usr/bin/env ruby

require 'rss'
require 'open-uri'
require 'net/http'

# Argument verification
unless ARGV.length == 2 || ARGV.length == 3
  puts "Usage: #{$0} file.txt /directory/to/dump/torrents optional:pagestosearch"
  puts "file example:"
  puts "anime name 1;1080;HorribleSubs"
  puts "anime name 2;720;HorribleSubs"
  exit 1
end

$logfile = File.dirname(ARGV[0]) + '/nyaa.txt'
time1 = Time.new
f = File.open($logfile, 'a')

old_out = $stdout
$stdout = f

if ARGV.length == 2
  puts "searched " + time1.inspect
else
  puts "searched " + time1.inspect + "   " + ARGV[2]
end

f.close

$stdout = old_out

def main()
  #reading the file passed in parameter
  file = ARGV[0]
  if ! File.exist?("#{file}")
    puts "#{file} does not exist..."
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
  if ARGV.length == 2
    offset = 1
  else
    offset = ARGV[2].to_i
  end
  for i in 1..offset
    nyaa_rss_url = "http://www.nyaa.se/?page=rss&cats=1_37&offset=#{i}"
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
        if found == search_strings.length
          download_torrent(item.link, item.title)

          time1 = Time.new
          f = File.open($logfile, 'a')
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
