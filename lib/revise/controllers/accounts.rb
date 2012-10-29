module Revise
  module Controllers
    module Accounts
      def self.extended(klass)
        klass.controllers :accounts do
          before(:show, :edit, :update, :destroy) do  
            @account = current_account   
            halt 403, 'Login first' unless @account
          end

          get :new, :map => '/accounts/new', :priority => :low do
            @account = Account.new
            render 'accounts/new'
          end

          post :create, :map => '/accounts', :priority => :low do
            if current_account  
              flash[:notice] = "You are already registered"  
              redirect_back_or_default(url(:main, :index))
            end 

            @account = Account.new(params[:account])   
            if @account.save  
              redirect url(:main, :index)
            else
              status 400
              render 'accounts/new'
            end
          end

          get :edit, :map => '/accounts/edit', :priority => :low do
            respond(@account)
          end

          put :update, :map => '/accounts', :priority => :low do  
            @account.update_attributes!(params[:account])  
            respond(@account, url(:accounts, :edit))
          end   

          delete :destroy, :map => '/accounts', :priority => :low do
            if current_account.respond_to?(:archive)
              destroyed = current_account.archive
            else
              destroyed = current_account.destroy
            end

            if destroyed
              flash[:notice] = "You have successfully deleted your account. It is disabled for now and will be completely 
                removed within 48 hours."  
            else
              flash[:warning] = "Couldn't Delete Your Account"
            end
            redirect_back_or_default(url(:main, :index))
          end   
        end
      end
    end
  end
end
