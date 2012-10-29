source :rubygems

# Server requirements
gem 'thin', :group => :development

# Project requirements
gem 'rake'
gem 'orm_adapter'
gem 'activesupport'

# Component requirements
gem 'bcrypt-ruby', :require => "bcrypt"
gem 'compass'
gem 'slim'
gem 'mongo_mapper'
gem 'bson_ext', :require => "mongo"
gem 'ffaker'
gem 'padrino-responders', :git => 'git://github.com/bookworm/padrino-responders.git'
gem 'compass_twitter_bootstrap'
gem "padrino-fields", :git => 'git://github.com/bookworm/padrino-fields.git', :require => 'padrino-fields' 
gem 'padrino-flash', :require => 'padrino-flash'

# Test requirements
group :test do
  gem 'mini_shoulda',        :require => 'mini_shoulda'
  gem 'minitest', "~>2.6.0", :require => 'minitest/autorun'
  gem 'rack-test',           :require => 'rack/test'
  gem 'ffaker',              :require => 'ffaker'
  gem 'factory_girl',        :require => 'factory_girl'
  gem 'mocha',               :require => false
end

# Development requirements
group :development do 
  gem 'ffaker'
  gem 'factory_girl'
end

# Padrino 
gem 'padrino'
