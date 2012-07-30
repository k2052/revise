require 'revise/core_ext/string'
require 'active_support'
require 'active_support/core_ext/numeric/time'
require 'orm_adapter'
require 'set'
require 'securerandom'
require 'revise/core_ext/module'
require 'revise/helpers/core'
require 'padrino/revise'

module Revise 
  MODULES    = {} 
  HELPERS    = []
  CONTROLERS = []
  MAILERS    = []

  autoload :Models,      'revise/models'
  autoload :ParamFilter, 'revise/param_filter'

  module Controllers
    autoload :Accounts,      'revise/controllers/accounts'
    autoload :Confirmations, 'revise/controllers/confirmations'
    autoload :Main,          'revise/controllers/main'
    autoload :Recovery,      'revise/controllers/recovery'
    autoload :Sessions,      'revise/controllers/sessions'
  end

  module Helpers
    autoload :Authentication, 'revise/helpers/authentication'
  end

  module Mailers
    autoload :Confirmable, 'revise/mailers/confirmable'
    autoload :Recoverable, 'revise/mailers/recoverable'
  end

  module Models
    autoload :Authenticatable,         'revise/models/authenticatable'
    autoload :Confirmable,             'revise/models/confirmable'
    autoload :DatabaseAuthenticatable, 'revise/models/database_authenticatable'
    autoload :Recoverable,             'revise/models/recoverable'
  end

  mattr_accessor :app
  mattr_accessor :mailer_from
  @@mailer_from = nil

  mattr_accessor :pepper
  @@pepper = nil

  mattr_accessor :stretches
  @@stretches = 10

  mattr_accessor :allow_unconfirmed_access_for
  @@allow_unconfirmed_access_for = 0.days

  mattr_accessor :confirm_within
  @@confirm_within = nil

  mattr_accessor :confirmation_keys
  @@confirmation_keys = [:email]

  mattr_accessor :reconfirmable
  @@reconfirmable = false

  mattr_accessor :reset_password_keys
  @@reset_password_keys = [:email]

  mattr_accessor :reset_password_within
  @@reset_password_within = 6.hours

  mattr_accessor :case_insensitive_keys
  @@case_insensitive_keys = [:email]

  mattr_accessor :strip_whitespace_keys
  @@strip_whitespace_keys = []

  def self.setup
    yield self
  end
end

require 'revise/models'
require 'revise/orm/mongo_mapper'
require 'padrino/revise'

I18n.load_path += Dir["#{File.dirname(__FILE__)}/revise/locale/**/*.yml"]