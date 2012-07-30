PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path('../../config/boot', __FILE__)

class MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    ##
    # You can handle all padrino applications using instead:
    #   Padrino.application
    ReviseDemoApp.tap { |app|  }
  end
end

ReviseDemoApp.set :delivery_method, :smtp => { 
  :address              => '127.0.0.1',
  :port                 => 1025,
  :user_name            => '',
  :password             => ''
}