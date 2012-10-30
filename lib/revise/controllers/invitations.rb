module Revise
  module Controllers
    module Invitations
      def self.extended(klass)
        klass.controllers :invitations do
          before(:new, :create) do
            halt 403, 'Login first' unless current_account
          end

          before(:new, :create) do
            halt 403, "You've no invitations left" unless current_account.has_invitations_left? || current_account.role?(:admin)
          end

          get :new, :map => '/invitations/new', :priority => :low do
            @account = Account.new
            render 'invitations/new'
          end

          post :create, :map => '/invitations', :priority => :low do
            @account = Account.invite!(params[:account], current_account)

            if @account.errors.empty?
              flash[:notice] = "You've invited #{params[:account][:email]}"
              redirect url(:main, :index)
            else
              status 400
              render 'invitations/new'
            end
          end

          get :edit, :map => '/invitations/:invitation_token', :priority => :low do
            if params[:invitation_token] && @account = Account.to_adapter.find_first(:invitation_token => params[:invitation_token])
              render 'invitations/edit'
            else
              status 404
              flash.now[:alert] = "Invitation Token Invalid"
              render 'invitations/404'
            end
          end

          put :update, :map => '/invitations/:invitation_token', :priority => :low do
            @account = Account.accept_invitation!(params[:account])

            if @account.errors.empty?
              flash[:notice] = "Accepted Invitation. Now login"
              respond(@account, url(:sessions, :new))
            else
              render 'invitations/edit'
            end
          end
        end
      end
    end
  end
end
