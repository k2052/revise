# Introduction

Revise is a authentication gem for Padrino heavily inspired by (and significant portions of code borrowed from) [Devise](https://github.com/plataformatec/devise). 
It supports Mongomapper and Mongoid with hopefully more ORMs being supported soon. 

It currently provides the following;

1. Registration CRUD
2. Sessions CRUD
3. Recovery
4. Confirmation
5. Invitations

# Warning! Early alpha phase, use at your own risk!

Although fully tested and being used in production on my apps, Revise is not quite up to par. It needs a bit of work still. 
Please only use it if you're confident in your ability to debug bugs and fix them.
Pull Requests are very welcome!

# Usage

1. Add the development version of [padrino-responders](https://github.com/bookworm/padrino-responders) to your gem file

```ruby
  gem 'padrino-responders', :git => 'git://github.com/bookworm/padrino-responders.git'
```

2. Add the gem to your gem file 

```ruby 
  gem 'revise'
```

3. Add the following to your app/app.rb file

```ruby
  register Padrino::Admin::AccessControl
  register Padrino::Revise
  revise_for :accounts
  set :session_id, :dragons
  enable  :sessions
  disable :store_location
  set :login_page, '/sessions/new'
```

4. Configure Revise on your Account model. Below is an example utilizing all available features

```ruby
  class Account
    include MongoMapper::Document
    revise :authenticatable, :database_authenticatable, :confirmable, :recoverable, :invitable

    # Keys
    key :name,                   String
    key :first_name,             String
    key :last_name,              String
    key :username,               String
    key :email,                  String
    key :encrypted_password,     String
    key :role,                   String  

    ## Confirmations
    key :confirmation_token,     String
    key :confirmed_at,           Time
    key :unconfirmed_email,      String
    key :confirmation_sent_at,   Time

    ## Recovery
    key :reset_password_sent_at, Time
    key :reset_password_token,   String
    
    ## Invitations
    key :invitation_token,       String
    key :invitation_sent_at,     Time 
    key :invitation_accepted_at, Time 
    key :invitation_limit,       Integer
    key :invited_by_id,          ObjectId
  end
```

5. Configure Revise (usually you want to place this in lib/revise_plugin.rb)

```ruby
  require 'revise'

  Revise.setup do |config|
    config.pepper                = 'notsalt'
    config.mailer_from           = 'test_email@localhost'
    config.case_insensitive_keys = [:email]
    config.strip_whitespace_keys = [:email]
    config.reconfirmable         = true
  end
``` 

Look at lib/revise.rb for all the available configuration options.

# Customizing

Since Padrino does not have controllers as classes Revise uses route priorities to allow you to over-ride it's default routes.
Upon registration with the Padrino app (`register Padrino::Revise; revise_for :accounts`) Revise includes it's controller routes into the app.

## Requiring Invitations For Registration

The simplest way to do this is to disable the /accounts/new route with a before filter; then require your users to 
register at invitations route.

```ruby
  AppName.controllers :accounts do 
    before(:new, :create) do
      halt 403, 'You need an invitation to register'
    end
  end
```

# Plans/Roadmap

1. Omniauth support
2. Datamapper support
3. Improve README/Docs

# Credits

Most bits ported from [Devise](https://github.com/plataformatec/devise)
Invitation bits ported from [devise_invitable](https://github.com/scambra/devise_invitable)

# License 

MIT License. 
