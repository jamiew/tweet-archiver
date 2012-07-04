tweet-archive
=============

Saves tweets from Twitter. Can be run on Heroku for free (only uses 1 dyno)

* Save tweets as text files
* Save tweets as database records
* screenshots
* upload said screenshot to imgur
* Post to Twitter when tweets match

Usage
-----

Copy config.sample.yml to config.yml and edit

You can generate Twitter OAuth tokens using

```bash
bundle exec rake tweetscan
```

Or with Foreman, which is how its run on Heroku:

```bash
bundle exec foreman start
```

Run on Heroku
-------------

We just bulk-stash a JSON version of the config.yml in a Heroku variable to use for configuration. Ghetto but works great!

```bash
cd tweet-archive
# edit config.yml; test locally that it all works
heroku create mytweets --stack=cedar
heroku config:add TWEET_ARCHIVE_CONFIG=$(ruby -e "require 'yaml'; require 'json'; puts YAML.load(File.open('config.yml').read).to_json")
git push heroku master
heroku scale stream=1
```

TODO
----

* needs a better name
* S3 or Dropbox file-saving support (like IFTTT)
* post to IRC/HipChat/Campfire/XMPP
* could be fun to hack GitHub or Pastebin et al to use as tweet storage engines

Contributing
------------

1. Fork it
2. Create your feature branch (it checkout -b my-new-feature
3. Commit your changes (it commit -am 'Added some feature'
4. Push to the branch (it push origin my-new-feature
5. Create new Pull Request



Authors
-------

* [@jamiew](https://github.com/jamiew)

