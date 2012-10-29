module Revise
  module Controllers
    module Sessions
      def self.extended(klass)  
        klass.controllers :sessions do
          get :new, :map => '/sessions/new', :priority => :low do
            render "/sessions/new", nil, :layout => false
          end
        
          post :create, :map => '/sessions', :priority => :low do
            authenticate()
          end
        
          delete :destroy, :map => '/sessions', :priority => :low do
            set_current_account()
            redirect url(:sessions, :new)
          end
        end
      end
    end
  end
end
