module Revise
  module Models
    module Recoverable
      extend ActiveSupport::Concern

      MAILERS     = ['Recoverable']
      HELPERS     = []
      CONTROLLERS = ['Recovery']

      def self.required_fields(klass)
        [:reset_password_sent_at, :reset_password_token, :email]
      end

      def reset_password!(new_password, new_password_confirmation)
        self.password              = new_password
        self.password_confirmation = new_password_confirmation

        if valid?
          clear_reset_password_token
          after_password_reset
        end

        save
      end

      def send_reset_password_instructions
        generate_reset_password_token! if should_generate_reset_token?
        send_revise_notification(:recoverable, :reset_password_instructions, self.name, self.email, self.reset_password_token)
      end

      def reset_password_period_valid?
        reset_password_sent_at && reset_password_sent_at.utc >= self.class.reset_password_within.ago
      end

      # Generates a new random token for reset password
      def generate_reset_password_token
        self.reset_password_token   = self.class.reset_password_token
        self.reset_password_sent_at = Time.now.utc
        self.reset_password_token
      end

      # Resets the reset password token with and save the record without
      # validating
      def generate_reset_password_token!
        generate_reset_password_token && save(:validate => false)
      end

      protected
        def should_generate_reset_token?
          reset_password_token.nil? || !reset_password_period_valid?
        end

        # Removes reset_password token
        def clear_reset_password_token
          self.reset_password_token   = nil
          self.reset_password_sent_at = nil
        end

        def after_password_reset
        end

      module ClassMethods
        # Attempt to find a user by its email. If a record is found, send new
        # password instructions to it. If not user is found, returns a new user
        # with an email not found error.
        # Attributes must contain the user email
        def send_reset_password_instructions(attributes={})
          recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
          recoverable.send_reset_password_instructions if recoverable.persisted?
          recoverable
        end

        # Generate a token checking if one does not already exist in the database.
        def reset_password_token
          generate_token(:reset_password_token)
        end

        # Attempt to find a user by its reset_password_token to reset its
        # password. If a user is found and token is still valid, reset its password and automatically
        # try saving the record. If not user is found, returns a new user
        # containing an error in reset_password_token attribute.
        # Attributes must contain reset_password_token, password and confirmation
        def reset_password_by_token(attributes={})
          recoverable = find_or_initialize_with_error_by(:reset_password_token, attributes[:reset_password_token])
          if recoverable.persisted?
            if recoverable.reset_password_period_valid?
              recoverable.reset_password!(attributes[:password], attributes[:password_confirmation])
            else
              recoverable.errors.add(:reset_password_token, :expired)
            end
          end
          recoverable
        end

        Revise::Models.config(self, :reset_password_keys, :reset_password_within)
      end
    end
  end
end
