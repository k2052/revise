require 'ffaker' 

admin_account = Account.first(:role => "admin")

unless admin_account
  email     = shell.ask "Which email do you want use for logging into admin?"
  password  = shell.ask "Tell me the password to use:"

  shell.say ""

  account = Account.create(:email => email, :name => "Foo", :surname => "Bar", :password => password, 
    :password_confirmation => password, :role => "admin")

  if account.valid?
    shell.say "================================================================="
    shell.say "Account has been successfully created, now you can login with:"
    shell.say "================================================================="
    shell.say "   email: #{email}"
    shell.say "   password: #{password}"
    shell.say "================================================================="
  else
    shell.say "Sorry but some thing went wrong!"
    shell.say ""
    account.errors.full_messages.each { |m| shell.say "   - #{m}" }
  end

  shell.say ""
end

## 
# Accounts
#
unless Padrino.env == :production
  shell.say "Adding 5 unconfirmed Accounts"
  5.times do |i| 
    account = Account.new(:email => Faker::Internet.email, :username => Faker::Internet.user_name, 
                          :name => Faker::Name.name, :password => 'testpass', 
                          :password_confirmation => 'testpass')    
    account.save 
  end

  shell.say "Adding 5 confirmed Accounts"
  5.times do |i| 
    account = Account.new(:email => Faker::Internet.email, :username => Faker::Internet.user_name, 
                          :name => Faker::Name.name, :password => 'testpass', 
                          :password_confirmation => 'testpass')    
    account.save 

    account = Account.confirm_by_token(account.confirmation_token)
    account.save
  end
end