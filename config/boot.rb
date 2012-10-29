# Defines our constants
PADRINO_ENV  = ENV['PADRINO_ENV'] ||= ENV['RACK_ENV'] ||= 'development'  unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, PADRINO_ENV)

## Configure I18n
I18n.default_locale = :en

## Add helpers to mailer
Mail::Message.class_eval do
  include Padrino::Helpers::TranslationHelpers
end

Padrino.before_load do
  env_vars = File.join(File.dirname(__FILE__), 'heroku_env.rb')
  load(env_vars) if File.exists?(env_vars)
end

Padrino.after_load do
  require 'revise'

  Revise.setup do |config|
    config.pepper                = 'cats'
    config.mailer_from           = 'test_email@localhost'
    config.case_insensitive_keys = [:email]
    config.strip_whitespace_keys = [:email]
    config.reconfirmable         = true
  end
end

module CompassInitializer
  def self.registered(app)
    require 'sass/plugin/rack'
    require 'compass_twitter_bootstrap'

    Compass.configuration do |config|
      config.project_path    = Padrino.root
      config.sass_dir        = "app/stylesheets"
      config.project_type    = :stand_alone
      config.http_path       = "/"
      config.css_dir         = "public/stylesheets"
      config.images_dir      = "public/images"
      config.javascripts_dir = "public/javascripts"
      config.output_style    = :compressed
    end

    Compass.configure_sass_plugin!
    Compass.handle_configuration_change!

    app.use Sass::Plugin::Rack
  end
end

Padrino.load!