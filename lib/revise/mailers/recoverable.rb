module Revise
  module Mailers
    module Recoverable
      def self.extended(klass)
        klass.mailer :recoverable do 
          email :reset_password_instructions do |name, email, reset_password_token|
            from Revise.mailer_from
            to email
            subject t('revise.recoverable.reset_password_instructions.subject', :domain => ENV['DOMAIN'])
            locals :name => name, :email => email, :reset_password_token => reset_password_token
            render 'revise/reset_password_instructions'
            content_type :html 
          end
        end
      end
    end
  end
end
