module Revise
  module Models
    module Authenticatable
      extend ActiveSupport::Concern

      MAILERS     = []
      HELPERS     = ['Authentication']
      CONTROLLERS = ['Main', 'Sessions', 'Accounts']

      BLACKLIST_FOR_SERIALIZATION = [:encrypted_password, :reset_password_token, :reset_password_sent_at, :role,
        :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip,
        :last_sign_in_ip, :password_salt, :confirmation_token, :confirmed_at, :confirmation_sent_at,
        :remember_token, :unconfirmed_email, :failed_attempts, :unlock_token, :locked_at, :authentication_token, :role, 
        :roles]

      included do
        before_validation :downcase_keys
        before_validation :strip_whitespace
        attr_accessor :skip_email
      end

      def self.required_fields(klass)
        [:role]
      end

      def valid_for_authentication?
        block_given? ? yield : true
      end

      def unauthenticated_message
        :invalid
      end

      def active_for_authentication?
        true
      end

      def inactive_message
        :inactive
      end

      def password_required?
        encrypted_password.blank? || password.present?
      end

      def role?(role)
        return false unless self.respond_to?(:role)
        return self.role.to_sym == role.to_sym
      end

      array = %w(serializable_hash)
      array << "to_xml"

      array.each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__
          def #{method}(options=nil)
            options ||= {}
            options[:except] = Array(options[:except])

            if options[:force_except]
              options[:except].concat Array(options[:force_except])
            else
              options[:except].concat BLACKLIST_FOR_SERIALIZATION
            end
            super(options)
          end
        RUBY
      end

      protected

      def send_revise_notification(resource, notification, *attributes)
        return false if self.email.blank?
        Revise.app.deliver(resource, notification, *attributes) unless @skip_email
      end

      def downcase_keys
        self.class.case_insensitive_keys.each { |k| self[k].try(:downcase!) }
      end

      def strip_whitespace
        self.class.strip_whitespace_keys.each { |k| self[k].try(:strip!) }
      end

      module ClassMethods
        Revise::Models.config(self, :authentication_keys, :request_keys, :strip_whitespace_keys,
          :case_insensitive_keys, :http_authenticatable, :params_authenticatable, :skip_session_storage)

        def find_for_authentication(conditions)
          find_first_by_auth_conditions(conditions)
        end

        def find_first_by_auth_conditions(conditions)
          to_adapter.find_first revise_param_filter.filter(conditions)
        end

        def find_or_initialize_with_error_by(attribute, value, error=:invalid) #:nodoc:
          find_or_initialize_with_errors([attribute], { attribute => value }, error)
        end

        # Find an initialize a group of attributes based on a list of required attributes.
        def find_or_initialize_with_errors(required_attributes, attributes, error=:invalid) #:nodoc:
          attributes = attributes.slice(*required_attributes)
          attributes.delete_if { |key, value| value.blank? }

          if attributes.size == required_attributes.size
            record = find_first_by_auth_conditions(attributes)
          end

          unless record
            record = new

            required_attributes.each do |key|
              value = attributes[key]
              record.send("#{key}=", value)
              record.errors.add(key, value.present? ? error : :blank)
            end
          end

          record
        end

        protected
          def revise_param_filter
            @revise_param_filter ||= Revise::ParamFilter.new(case_insensitive_keys, strip_whitespace_keys)
          end

          def generate_token(column)
            loop do
              token = String.friendly_token
              break token unless to_adapter.find_first({ column => token })
            end
          end
      end
    end
  end
end
