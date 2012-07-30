module Revise
  module Mailers
    module Confirmable
      def self.extended(klass)
        klass.mailer :confirmable do 
          email :confirmation_instructions do |name, email, confirmation_token|
            from Revise.mailer_from
            to email
            subject t('revise.confirmable.confirmation_instructions.subject', :domain => ENV['DOMAIN'])
            locals :name => name, :email => email, :confirmation_token => confirmation_token
            render 'revise/confirmation_instructions'
            content_type :html 
          end
        end
      end
    end
  end
end