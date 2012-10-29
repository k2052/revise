module Revise
  module Mailers
    module Invitable
      def self.extended(klass)
        klass.mailer :invitable do 
          email :invitation_instructions do |name, email, invitation_token|
            from Revise.mailer_from
            to email
            subject t('revise.invitable.invitation_instructions.subject', :domain => ENV['DOMAIN'])
            locals :name => name, :email => email, :invitation_token => invitation_token
            render 'revise/invitation_instructions'
            content_type :html 
          end
        end
      end
    end
  end
end
