module Revise
  module Controllers
    module Recovery
      def self.extended(klass)
        klass.controllers :accounts do
          before do
            halt 403, "You're already logged in?" if current_account
          end

          before(:forgot_password, :reset_password) do
            @account = Account.new
          end

          get :forgot_password, :map => '/accounts/forgot-password', :priority => :low do
            render 'accounts/forgot_pass'
          end

          post :send_reset_password_instructions, :map => '/accounts/forgot-password', :priority => :low do
            account = Account.find_by_email(params[:email])

            if account
              account.send_reset_password_instructions 
              flash[:notice] = "You've been sent an email with instructions"
            else
              status 404
              flash[:warning] = "No email by that name was found"
            end

            redirect(url(:main, :index))
          end

          get :reset_password, :map => '/accounts/reset-password/:reset_password_token', :priority => :low do
            flash[:error] = "Reset Password Token Does Not Exist" unless Account.find_by_reset_password_token(params[:reset_password_token])
            render 'accounts/reset_password'
          end

          put :new_password, :map => '/accounts/reset-password/:reset_password_token', :priority => :low do
            account = Account.reset_password_by_token({:password => params[:password], 
              :password_confirmation => params[:password_confirmation], 
              :reset_password_token  => params[:reset_password_token]})

            if account
              if account.errors.empty?
                flash[:notice] = "Account Password Has Been Reset"
                redirect(url(:main, :index))
              else
                flash[:error] = account.errors.full_messages()
                redirect(url(:main, :index))
              end
            else
              flash[:error] = "Reset Password Token Does Not Exist"
              status 404
              render 'accounts/reset_password_token_404'
            end
          end
        end
      end
    end
  end
end
