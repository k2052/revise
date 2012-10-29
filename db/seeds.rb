require 'ffaker' 
require 'factory_girl'

FactoryGirl.definition_file_paths = [
  File.join(Padrino.root, 'test', 'factories')
]
FactoryGirl.find_definitions

# Add an admin account if there isn't one
admin_account = Account.first(:role => "admin")
unless admin_account
  email      = shell.ask "Which email do you want use for logging into admin?"
  password   = shell.ask "Tell me the password to use:"
  first_name = shell.ask "What is your first name?"
  last_name  = shell.ask "What is your last name?"

  shell.say ""

  account = Account.create(:email                 => email,
                           :first_name            => first_name,
                           :last_name             => last_name, 
                           :password              => password,
                           :password_confirmation => password,
                           :role                  => 'admin')

  if account.valid?
    shell.say "================================================================="
    shell.say "Account has been successfully created, now you can login with:"
    shell.say "================================================================="
    shell.say "   email: #{email}"
    shell.say "   password: #{password}"
    shell.say "================================================================="
  else
    shell.say "Sorry but something went wrong!"
    account.errors.full_messages.each { |m| shell.say "   - #{m}" }
  end

  shell.say ""
end