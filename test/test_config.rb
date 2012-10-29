PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path('../../config/boot', __FILE__)
require "mocha"

ReviseDemoApp.set :delivery_method, :smtp => { 
  :address              => '127.0.0.1',
  :port                 => 1025,
  :user_name            => '',
  :password             => ''
}

FactoryGirl.definition_file_paths = [
  File.join(Padrino.root, 'test', 'factories')
]
FactoryGirl.find_definitions

class MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    ReviseDemoApp.tap { |app|  }
  end
end
