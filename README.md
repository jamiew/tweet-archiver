tweet-archiver (jdubs edition)
=============================

Saves tweets from Twitter's streaming API. Can be run on Heroku for free (Cedar stack; only needs 1 dyno)

There's a bunch of these out there, but this one does all the things I want.

* Saves tweets as text files
* Saves tweets as database records
* Takes screenshots
* Uploads said screenshots to imgur
* Posts to Twitter

All the actual code is in the Rakefile (FIXME)

Usage
-----

Copy config.sample.yml to config.yml and edit

You can generate Twitter OAuth tokens by registering a new application on
<http://dev.twitter.com>, making it read-write, and clicking 'Generate tokens'

```bash
bundle exec rake tweetscan
```

Or with Foreman, which is how its run on Heroku:

```bash
bundle exec foreman start
```

Run on Heroku
-------------

We just bulk-stash a JSON version of the config.yml in a Heroku variable to use for configuration. Sort of ghetto, but works great.

```bash
cd tweet-archive
# edit config.yml; test locally that it all works
heroku create mytweets --stack=cedar
heroku config:add TWEET_ARCHIVE_CONFIG=$(ruby -e "require 'yaml'; require 'json'; puts YAML.load(File.open('config.yml').read).to_json")
git push heroku master
heroku scale stream=1
```

Note that running two instances of this with the same credentials seems verboten by the streaming API; just run one instance.

TODO
----

* needs a better name
* S3 or Dropbox file-saving support (like IFTTT)
* post to IRC/HipChat/Campfire/XMPP
* could be fun to hack GitHub or Pastebin et al to use as tweet storage engines

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


Authors
-------

* [@jamiew](https://github.com/jamiew)

