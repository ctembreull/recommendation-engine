## Recommendation Engine

An elasticsearch instance called via a Ruby/Grape/Rack API to provide recommended matching users for any list of skills and roles.

#### 1. Install RVM
You can find detailed instructions for this at (http://rvm.io), but the short version is:

    christembreull@host ~
    $ \curl -sSL https://get.rvm.io | bash -s stable --ruby=2.2.1

You'll want to ensure that your ~/.rvmrc file contains the line:

    # ~/.rvmrc
    rvm_gemset_create_on_use_flag=1

If you don't have ruby2.2.1 (the latest stable version as of this writing), install it with

    christembreull@host ~
    $ rvm install 2.2.1

#### 2. Install Elasticsearch

    christembreull@host ~
    $ brew install elasticsearch

This is always easiest via Homebrew, and this document will assume that Elasticsearch was installed this way. 

On OS-X, you will need to start the services for elasticsearch, you can do so as follows:

To have launchd start elasticsearch at login:
    
    ln -sfv /usr/local/opt/elasticsearch/*.plist ~/Library/LaunchAgents

Then to load elasticsearch now:

    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch.plist

Or, if you don't want/need launchctl, you can just run:

    elasticsearch --config=/usr/local/opt/elasticsearch/config/elasticsearch.yml
    
Make sure your server is started with the following command `user$ curl -XGET http://127.0.0.1:9200` you'll see a similar status JSON document if the server is running:

    user@host ~
    $ curl -XGET http://127.0.0.1:9200
    {
      "status" : 200,
      "name" : "Korrek",
      "cluster_name" : "elasticsearch_christembreull",
      "version" : {
        "number" : "1.4.4",
        "build_hash" : "c88f77ffc81301dfa9dfd81ca2232f09588bd512",
        "build_timestamp" : "2015-02-19T13:05:36Z",
        "build_snapshot" : false,
        "lucene_version" : "4.10.3"
      },
      "tagline" : "You Know, for Search"
    }

#### 3. Clone this project

    christembreull@host ~/dev/comotion
    $ git clone git@github.com:ctembreull/recommendation-engine

#### 4. Setup a .rvmrc for the project in the root checkout directory
It's in the .gitignore, so it won't be checked in. Mine looks like:

    # /project_dir/.rvmrc
    rvm use 2.2.1@recommendation-engine

You'll need to make sure this rvmrc file is loaded:

    christembreull@host (master) ~/dev/comotion/recommendation-engine
    $ cd .

You'll be prompted; answer 'yes'.

#### 5. Bundle Install

    christembreull@host (master) ~/dev/comotion/recommendation-engine
    $ bundle install

#### 6. Link your scripts into the Elasticsearch config directory
Again, these directions assume you've installed eElasticsearch via Homebrew. Your config directory may be different otherwise.

    christembreull@host (master) ~/dev/comotion/recommendation-engine
    $ mkdir /usr/local/opt/elasticsearch/config/scripts
    $ ln -sfv ./scripts/cvg_score.groovy !$

In the elasticsearch logs, you'll see:

    [2015-03-19 12:18:34,170][INFO ][script                   ] [Korrek] compiling script file [/usr/local/Cellar/elasticsearch/1.4.4/config/scripts/cvg_score.groovy]

#### 7. Seed your elasticsearch instance

    christembreull@host (master) ~/dev/comotion/recommendation-engine
    $ ruby scripts/seed.rb

#### 8. Start the server
You can start it in non-reloading mode simply by running:

    christembreull@host (master) ~/dev/comotion/recommendation-engine
    $ rackup -E development

If you start the server this way, you'll have to restart it after every change, but you can start in self-reloading development mode by running:

    christembreull@host (master) ~/dev/comotion/recommendation-engine
    $ bundle exec guard

#### 9. Test your installation
Issue an API call to see what you get back.

    christembreull@host (master) ~/dev/comotion/recommendation-engine
    $ curl -XGET http://localhost:9292/recommendations/test

## Congratulations! You're running the Comotion Recommendation Engine!
