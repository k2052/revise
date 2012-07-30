require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "Accounts Controller" do
  setup do 
    header 'Accept', 'text/html' 

    @account  = Account.first(:role.ne => 'admin')       
    post '/sessions', {:email => @account.email, :bypass => true}  
    assert last_response.status == 302
  end

  teardown do
    delete '/sessions'
    assert last_response.status == 302
  end

  should "return a new page" do
    delete '/sessions'
    assert last_response.status == 302
  
    get '/accounts/new'
    assert last_response.status == 200
  end

  should "create a new account" do
    delete '/sessions'
    assert last_response.status == 302
  
    name = Faker::Lorem.words(2)
    account_params = {:first_name => name[0], :last_name => name[1], :email => 'cows@example.org', :password => 'testpass',
     :password_confirmation => 'testpass'}
  
    post '/accounts', {:account => account_params}
    assert last_response.status == 302
  
    account = Account.first(:first_name => name[0])
    assert account
  end
  
  should "return an edit page" do
    get '/accounts/edit'
    assert last_response.status == 200
  end

  should "update an account" do
    delete '/sessions'
    assert last_response.status == 302

    account = Account.first(:last_name.ne => 'Johnson')  

    post '/sessions', {:email => account.email, :bypass => true}  
    assert last_response.status == 302 

    put '/accounts', {:account => {:last_name => 'Johnson'}}
    assert last_response.status == 302
  
    account = Account.find_by_id(account.id)
    assert account.last_name == 'Johnson'
  end

  should "delete an account" do
    delete '/sessions'
    assert last_response.status == 302
  
    account  = Account.first(:role.ne => 'admin')       
    post '/sessions', {:email => account.email, :bypass => true}  
    assert last_response.status == 302
  
    delete '/accounts'
    assert last_response.status == 302
  
    assert Account.find_by_id(account.id).nil?
  end

  should "confirm an account" do
    delete '/accounts'
    assert last_response.status == 302
  
    account  = Account.first(:role.ne => 'admin', :confirmed_at => nil)       
    post '/sessions', {:email => account.email, :bypass => true}  
    assert last_response.status == 302
  
    get "/accounts/confirm/#{account.confirmation_token}"
    assert last_response.status == 200
  
    account = Account.find_by_id(account.id)
    assert account.confirmed?
  end

  should "return a forgot_pass page" do
    delete '/sessions'
    assert last_response.status == 302
  
    get '/accounts/forgot-password'
    assert last_response.status == 200
  end
  
  should "reset a password" do
    delete '/sessions'
    assert last_response.status == 302
  
    account = Account.first(:reset_password_token => nil)
  
    post '/accounts/forgot-password', {:email => account.email}
    assert last_response.status == 302
  
    account = Account.find_by_id(account.id)
    assert account.reset_password_token
  
    get "/accounts/reset-password/#{account.reset_password_token}"
    assert last_response.status == 200
  
    put "/accounts/reset-password/#{account.reset_password_token}", {:password => 'resetpass', :password_confirmation => 'resetpass'}
    assert last_response.status == 302
  
    old_pass_crypt = account.encrypted_password
    account = Account.find_by_id(account.id)
    assert account.encrypted_password != old_pass_crypt
  end

  should "refuse to return an edit page" do
    delete '/sessions'
    assert last_response.status == 302

    get '/accounts/edit'
    assert last_response.status == 403
  end

  should "refuse to update" do
    delete '/sessions'
    assert last_response.status == 302

    put '/accounts'
    assert last_response.status == 403
  end

  should "refuse to delete an account" do
    delete '/sessions'
    assert last_response.status == 302

    delete '/accounts'
    assert last_response.status == 403
  end
end