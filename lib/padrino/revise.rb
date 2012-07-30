module Padrino
  module Revise
    def self.registered(app)
      app.helpers ::Revise::Helpers::Core
      app.send(:extend, ::Revise::Helpers::Core)
    end
  end
end