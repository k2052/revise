class ReviseDemoApp < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  register CompassInitializer
  register Padrino::Revise
  register Padrino::Admin::AccessControl
  register Padrino::Responders
  register Padrino::Flash

  register PadrinoFields
  set :default_builder, 'PadrinoFieldsBuilder'

  enable :sessions

  revise_for :accounts
  
  set :delivery_method, :smtp => { 
    :address              => '127.0.0.1',
    :port                 => 1025,
    :user_name            => '',
    :password             => ''
  }
end