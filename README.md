# Nyaa downloader

this script search the rss feeds of nyaa.se using a file passed in parameter and download the torrents files to a specified directory. Useful to auto add new anime episode to a torrent client.

## How to use
First create a text file that you will fill with what you want to search.

Every line of the file will looks something like this:

```my anime name;720p;HorribleSubs```

This line for example would search for every rss item and download the torrent file when the item contains "my anime name", "720p" AND "HorribleSubs". You can have as many line as you want in the file. There is also no limit to how much search terms you can put by line.

Once your file is written you can launch the script with:

```./nyaa_dl.rb file.txt /directory```

You should probably put it in a cronjob or something so it would run a couple of times a day and download your new episode of "my anime name" when it comes out.

like

```0 15 * * * ruby /path/nyaa_dl.rb /path/anime.txt ~/path/animu/```

## Notes
nyaa_dl searches starting from the most recent torrents added to nyaa.se so this script is only useful for getting new episodes of ongoing animes.

Logs are in nyaa.txt.
