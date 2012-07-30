module Revise
  module Helpers
    module Authentication
      def authenticate()
        if account = Account.authenticate(params[:email], params[:password])
          set_current_account(account)
          redirect url(:main, :index)
        elsif Padrino.env == :development && params[:bypass] || Padrino.env == :test && params[:bypass]
          account = Account.find_by_email(params[:email])
          halt 400, "Email does not exist." unless account
          set_current_account(account)
          redirect url(:main, :index)
        else
          params[:email], params[:password] = h(params[:email]), h(params[:password])
          flash[:warning] = "Login or password wrong."
          redirect url(:sessions, :new)
        end
      end
    end
  end
end