### Introduction
Sample code to use Omniauth in conjunction with Sinatra.

### Derived from

Watch the [Railscast](http://railscasts.com/episodes/304-omniauth-identity?view=asciicast) to get an idea of how Omniauth can be used in Ruby.

#### Setup

There is an example configuration file in /config/application.yml.example. You will need to copy it to /config/application.yml and customize it to your own needs. 

You will also need to setup the database (see rake tasks below) and do a bundle install before the code will function.

#### Rake Tasks

    rake db:create_migration  # create an ActiveRecord migration
    rake db:migrate           # migrate the database (use version with VERSION=n)
    rake db:rollback          # roll back the migration (use steps with STEP=n)

* More on migrations on [sinatra-activerecord Github](https://github.com/janko-m/sinatra-activerecord)
* Integrated multiple omniauth provider. [More info](http://bernardi.me/using-multiple-omniauth-providers-with-omniauth-identity-on-the-main-user-model/)

#### Access irb console
To be able to do some dirty checks

    irb
    load 'app.rb'
    u = User.all

#### There are a few things that are vendor specific:

* Google - you have to enable the Google + API and the Contacts API from console.developers.google.com
* On most providers, you need to enable the callback urls and such, even for local testing(typically something like: http://localhost:9393/auth/google_oauth2/callback)
