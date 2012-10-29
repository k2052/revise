require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe 'Accounts Controller' do
  def sign_in(account=nil)
    account ||= FactoryGirl.create(:account)

    delete '/sessions'
    assert last_response.status == 302

    post '/sessions', {:email => account.email, :bypass => true}  
    assert last_response.status == 302
  end

  def send_invitation(email="#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org")
    post '/invitations', {:account => { :email => email}}
  end

  setup do 
    header 'Accept', 'text/html' 
    sign_in
  end

  teardown do
    delete '/sessions'
    assert last_response.status == 302
  end

  should 'not allow a non-authenticated account to send an invitation' do
    delete '/sessions'
  
    get '/invitations/new'
    assert last_response.status == 403
  end
  
  should 'let an authenticated account send an invitation' do
    email = "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org"
    send_invitation(email)
    assert last_response.status == 302
 
    account = Account.find_by_email(email)
    assert !account.invitation_token.nil?
  end
 
  should 'not allow a user with no invites left to send an invitation' do
    account                  = FactoryGirl.build(:account)
    account.invitation_limit = 0
    account.save
    sign_in(account)
 
    email = "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org"
    send_invitation(email)
    assert last_response.status == 403
  end
 
  should 'default a user with nil invitation_limit to Account.invitation_limit' do
    Account.stubs(:invitation_limit).returns(3)
 
    account = FactoryGirl.create(:account)
    assert account[:invitation_limit].nil?
    assert_equal 3, account.invitation_limit
    sign_in(account)
 
    send_invitation()
    
    account.reload
    assert_equal 2, account.invitation_limit
  end
 
  should 'not decrement invitation limit when trying to invite again a user which is invited' do
    Account.stubs(:invitation_limit).returns(3)
 
    account = FactoryGirl.create(:account)
    assert account[:invitation_limit].nil?
    assert_equal 3, account.invitation_limit
    sign_in(account)
 
    send_invitation()
    account.reload
    assert_equal 2, account.invitation_limit
 
    send_invitation()
    account.reload    
    assert_equal 1, account.invitation_limit
  end
 
  should 'set invited_by when user invites someone' do
    account = FactoryGirl.create(:account)
    sign_in(account)
 
    email = "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org"
    send_invitation(email)    
 
    invited_account = Account.find_by_email(email)
    assert !invited_account.nil?
    assert_equal account, invited_account.invited_by
  end
 
  should 'allow admin to send invitations anyway' do
    admin_account = FactoryGirl.create(:account_admin, :invitation_limit => 0)
    sign_in(admin_account)

    send_invitation
    assert last_response.status == 302
  end
end
