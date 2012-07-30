require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "Sessions Controller" do
  setup do 
    header 'Accept', 'text/html' 
  end

  should "respond with a new page" do
    get '/sessions/new'
    assert last_response.status == 200
  end
 
  should "create a new session and then destroy it" do
    account = Account.first()       
      
    post '/sessions', {:email => account.email, :bypass => true}  
    assert last_response.status == 302
 
    delete '/sessions'
    assert last_response.status == 302
 
    get '/accounts/edit'
    assert last_response.status == 403
  end

  should "refuse to create a session" do
    account = Account.first()       
      
    post '/sessions'
    assert last_response.status == 302

    get '/accounts/edit'
    assert last_response.status == 403
  end
end