module Revise
  module Controllers
    module Confirmations
      def self.extended(klass)
        klass.controllers :accounts do
          get :confirm, :map => '/accounts/confirm/:confirmation_token', :priority => :low do
            account = Account.confirm_by_token(params[:confirmation_token])
            if account
              if account.errors.empty?
                flash[:notice] = "Account Confirmed Please Login"
                render 'accounts/confirmed'
              else
                flash[:error] = account.errors.full_messages()
                render 'accounts/confirmed'
              end
            else
              flash[:error] = "Token Does Not Exist"
              status 404
              render 'accounts/confirmation_token_404'
            end
          end
        end
      end
    end
  end
end