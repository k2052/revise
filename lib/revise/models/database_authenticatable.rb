require 'bcrypt'

module Revise
  module Models
    module DatabaseAuthenticatable
      extend ActiveSupport::Concern

      MAILERS     = []
      HELPERS     = ['Authentication']
      CONTROLLERS = ['Sessions', 'Accounts']

      included do
        attr_reader :password, :current_password
        attr_accessor :password_confirmation
      end

      def valid_for_authentication?
        if super && valid_password?
          true
        else
          false
        end
      end

      def self.required_fields(klass)
        [:encrypted_password] + klass.authentication_keys
      end

      def password=(new_password)
        @password = new_password
        self.encrypted_password = password_digest(@password) if @password.present?
      end

      def valid_password?(password=nil)
        password = @password if password == nil

        return false if encrypted_password.blank?

        bcrypt   = ::BCrypt::Password.new(encrypted_password)
        password = ::BCrypt::Engine.hash_secret("#{password}#{self.class.pepper}", bcrypt.salt)

        String.secure_compare(password, encrypted_password)
      end

      def clean_up_passwords
        self.password = self.password_confirmation = nil
      end

      def update_with_password(params, *options)
        current_password = params.delete(:current_password)

        if params[:password].blank?
          params.delete(:password)
          params.delete(:password_confirmation) if params[:password_confirmation].blank?
        end

        result = if valid_password?(current_password)
          update_attributes(params, *options)
        else
          self.assign_attributes(params, *options)
          self.valid?
          self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
          false
        end

        clean_up_passwords
        result
      end

      def update_without_password(params, *options)
        params.delete(:password)
        params.delete(:password_confirmation)

        result = update_attributes(params, *options)
        clean_up_passwords
        result
      end

      def after_database_authentication
      end

      def authenticatable_salt
        encrypted_password[0,29] if encrypted_password
      end

    protected

      def password_digest(password)
        ::BCrypt::Password.create("#{password}#{self.class.pepper}", :cost => self.class.stretches).to_s
      end

      module ClassMethods
        Revise::Models.config(self, :pepper, :stretches)
        
        def authenticate(email, password)
          account = Account.find_by_email(email)
          return false unless account
          if account.valid_password?(password)
            return account
          else
            return false
          end
        end
      end
    end
  end
end
