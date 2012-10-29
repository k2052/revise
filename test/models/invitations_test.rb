require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe 'Account Model' do  
  should 'not generate invitation token after creating a record' do
    account = FactoryGirl.create(:account)
    assert account.invitation_token.nil?
  end

  should 'not regenerate invitation token each time' do
    account = FactoryGirl.create(:account)
    account.invite!

    token = account.invitation_token
    assert !account.invitation_token.nil?
    assert !account.invitation_sent_at.nil?

    3.times do
      account.invite!
      assert_equal token, account.invitation_token
    end
  end

  should 'set invitation sent at each time' do
   account = FactoryGirl.create(:account)
   account.invite!

   old_invitation_sent_at = 3.days.ago
   account.update_attributes!(:invitation_sent_at => old_invitation_sent_at)

   3.times do
     account.invite!
     assert old_invitation_sent_at != account.invitation_sent_at
     account.update_attributes!(:invitation_sent_at => old_invitation_sent_at)
   end
  end

  should 'not regenerate invitation token even after the invitation token is not valid' do
    account = FactoryGirl.create(:account)
    account.invite!

    token = account.invitation_token
    account.invitation_sent_at = 3.days.ago
    account.save
    account.invite!

    assert token == account.invitation_token
  end

  should 'test invitation sent at with invite_for configuration value' do
    account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :skip_email => true)

    Account.stubs(:invite_for).returns(nil)
    account.invitation_sent_at = Time.now.utc
    assert account.valid_invitation?

    Account.stubs(:invite_for).returns(nil)
    account.invitation_sent_at = 1.year.ago
    assert account.valid_invitation?

    Account.stubs(:invite_for).returns(0)
    account.invitation_sent_at = Time.now.utc
    assert account.valid_invitation?

    Account.stubs(:invite_for).returns(0)
    account.invitation_sent_at = 1.day.ago
    assert account.valid_invitation?

    Account.stubs(:invite_for).returns(1.day)
    account.invitation_sent_at = Time.now.utc
    assert account.valid_invitation?

    Account.stubs(:invite_for).returns(1.day)
    account.invitation_sent_at = 2.days.ago
    assert !account.valid_invitation?
  end

  should 'never generate the same invitation token for different users' do
    invitation_tokens = []
    3.times do
      account = FactoryGirl.create(:account)
      account.invite!
      token = account.invitation_token
      assert !invitation_tokens.include?(token)
      invitation_tokens << token
    end
  end

  should 'invite with multiple columns for invite key' do
    Account.stubs(:invite_key).returns(:email => Revise.email_regexp, :username => /\A.+\z/)
    
    account = Account.invite!(:email      => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", 
                              :username   => Faker::Internet.user_name, 
                              :skip_email => true)
    assert account.persisted?
    assert account.errors.empty?
  end

  should 'not invite with some missing columns when invite key is an array' do
    Account.stubs(:invite_key).returns(:email => Revise.email_regexp, :username => /\A.+\z/)
    account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :skip_email => true)
    assert account.new_record?
    assert account.errors.present?
  end

  should 'disallow login when invited' do
    invited_account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :skip_email => true)
    assert !invited_account.valid_password?('1234')
  end

  should 'set password and password confirmation from params' do
    invited_account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :skip_email => true)
    account         = Account.accept_invitation!(:invitation_token      => invited_account.invitation_token, 
                                                 :password              => 'testpass', 
                                                 :password_confirmation => 'testpass')
    assert account.valid_password?('testpass')
  end

  should 'set password and save the record' do
    account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :skip_email => true)

    old_encrypted_password = account.encrypted_password

    account = Account.accept_invitation!(:invitation_token      => account.invitation_token, 
                                         :password              => 'testpass', 
                                         :password_confirmation => 'testpass', 
                                         :skip_email            => true)
    assert old_encrypted_password != account.encrypted_password
  end

  should 'clear invitation token and set invitation_accepted_at while accepting the password' do
    account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :skip_email => true)

    assert account.invitation_token.present?
    assert account.invitation_accepted_at.nil?

    account.accept_invitation!()
    account.reload

    assert account.invitation_token.nil?
    assert account.invitation_accepted_at
  end

  should 'clear invitation token while resetting the password' do
    account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :skip_email => true)
    account.generate_reset_password_token!

    assert account.reset_password_token
    assert account.invitation_token

    Account.reset_password_by_token(:reset_password_token  => account.reset_password_token, 
                                    :password              => '123456789', 
                                    :password_confirmation => '123456789', 
                                    :skip_email            => true)
    assert account.reload.invitation_token.nil?
  end

  should 'return a record with invitation token and no errors to send invitation by email' do
    email = "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org"
    invited_account = Account.invite!(:email => email, :skip_email => true)

    assert invited_account.errors.blank?
    assert invited_account.invitation_token

    assert email == invited_account.email
    assert invited_account.persisted?
  end

  should 'set all attributes with no errors' do
    Account.stubs(:invite_key).returns(:email => Revise.email_regexp, :username => /\A.+\z/)
    username = "#{Faker::Internet.user_name}_#{rand(0...1000)}"
    invited_account = Account.invite!(:email      => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", 
                                      :username   => username)

    assert invited_account.errors.blank?
    assert username == invited_account.username
    assert invited_account.persisted?
  end

  should 'not validate other attributes when validate_on_invite is disabled' do
    validate_on_invite = Account.validate_on_invite
    Account.validate_on_invite = false
    invited_account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :username => "#{Faker::Internet.user_name}_#{rand(0...1000)}", :skip_email => true)
    assert invited_account.errors.empty?
    Account.validate_on_invite = validate_on_invite
  end

  should 'validate other attributes when validate_on_invite is enabled' do
    Account.stubs(:invite_key).returns(:email => Revise.email_regexp, :username => /\A.+\z/)
    validate_on_invite = Account.validate_on_invite
    Account.validate_on_invite = true
    invited_account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :username => 'invalid_username', :skip_email => true)
    assert invited_account.errors[:username].present?
    Account.validate_on_invite = validate_on_invite
  end

  should 'not validate password when validate_on_invite is enabled' do
    validate_on_invite = Account.validate_on_invite
    Account.validate_on_invite = true
    invited_account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :username => "#{Faker::Internet.user_name}_#{rand(0...1000)}")
    
    assert invited_account.errors.empty?
    assert invited_account.errors[:password].empty?
    Account.validate_on_invite = validate_on_invite
  end

  should 'validate other attributes when validate_on_invite is enabled and email is not present' do
    Account.stubs(:invite_key).returns(:email => Revise.email_regexp, :username => /\A.+\z/)
    validate_on_invite = Account.validate_on_invite
    Account.validate_on_invite = true
    invited_account = Account.invite!(:email => '', :username => 'invalid_username', :skip_email => true)
    
    assert invited_account.errors[:email].present?
    assert invited_account.errors[:username].present?
    Account.validate_on_invite = validate_on_invite
  end

  should 'return a record with errors if account was found by e-mail' do
    email = "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org"
    existing_account = FactoryGirl.create(:account, :email => email)
    account = Account.invite!(:email => email, :skip_email => true)
    assert account.email == existing_account.email
    assert account.errors[:email].present?
  end

  should 'return a record with errors if account with pending invitation was found by e-mail' do
    email = "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org"
    existing_account = Account.invite!(:email => email, :validate => false)
    account          = Account.invite!(:email => email, :validate => false)

     assert account.email == existing_account.email
     assert [] == account.errors[:email]

    resend_invitation = Account.resend_invitation

    begin
      Account.resend_invitation = false

      account = Account.invite!(:email => email, :skip_email => true)
      assert account.email == existing_account.email
      assert account.errors[:email].present?
    ensure
      Account.resend_invitation = resend_invitation
    end
  end

  should 'return a record with errors if account was found by e-mail with validate_on_invite' do
    Account.stubs(:invite_key).returns(:email => Revise.email_regexp, :username => /\A.+\z/)
    begin
      validate_on_invite = Account.validate_on_invite
      Account.validate_on_invite = true

      email            = "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org"
      existing_account = FactoryGirl.create(:account, :email => email)
      account          = Account.invite!(:email => email, :username => 'invalid_username', :skip_email => true)

      assert account.email == existing_account.email
      assert account.errors[:email].present?
      assert account.errors[:username].present?
    ensure
      Account.validate_on_invite = validate_on_invite
    end
  end

  should 'return a new record with errors if e-mail is blank' do
    invited_account = Account.invite!(:email => '', :skip_email => true)
    assert invited_account.new_record?
    assert ["can't be blank"] == invited_account.errors[:email]
  end

  should 'return a new record with errors if e-mail is invalid' do
    invited_account = Account.invite!(:email => 'invalid_email')
    assert invited_account.new_record?
    assert ["is invalid"] == invited_account.errors[:email]
  end

  should 'set all attributes with errors if e-mail is invalid' do
    Account.stubs(:invite_key).returns(:email => Revise.email_regexp, :username => /\A.+\z/)
    username = "#{Faker::Internet.user_name}_#{rand(0...1000)}"
    invited_account = Account.invite!(:email => 'invalid_email', :username => username, :skip_email => true)
    assert invited_account.new_record?
    assert username == invited_account.username
    assert invited_account.errors.present?
  end

  should 'find a account to set his password based on invitation_token' do
    account = FactoryGirl.create(:account)
    account.invite!
    invited_account = Account.accept_invitation!(:invitation_token => account.invitation_token, :skip_email => true)
    assert invited_account.email == account.email
  end

  should 'return a new record with errors if no invitation_token is found' do
    invited_account = Account.accept_invitation!(:invitation_token => 'invalid_token', :skip_email => true)
    assert invited_account.new_record?
    assert ['is invalid'] == invited_account.errors[:invitation_token]
  end

  should 'return a new record with errors if invitation_token is blank' do
    invited_account = Account.accept_invitation!(:invitation_token => '', :skip_email => true)
    assert invited_account.new_record?
    assert ["can't be blank"] == invited_account.errors[:invitation_token]
  end

  should 'return record with errors if invitation_token has expired' do
    Account.stubs(:invite_for).returns(10.hours)

    invited_account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :skip_email => true)
    invited_account.invitation_sent_at = 2.days.ago
    invited_account.save(:validate => false)

    account = Account.accept_invitation!(:invitation_token => invited_account.invitation_token)

    assert account == invited_account
    assert ["is invalid"] == account.errors[:invitation_token]
  end

  should 'set successfully account password given the new password and confirmation' do
    account = FactoryGirl.create(:account)
    account.invite!

    invited_account = Account.accept_invitation!(
      :invitation_token      => account.invitation_token,
      :password              => 'new_password',
      :password_confirmation => 'new_password',
      :skip_email            => true
    )
    account.reload

    assert account.valid_password?('new_password')
  end

  should 'return errors on other attributes even when password is valid' do
    account = FactoryGirl.create(:account)
    account.invite!

    invited_account = Account.accept_invitation!(
      :invitation_token      => account.invitation_token,
      :password              => 'new_password',
      :password_confirmation => 'new_password',
      :username              => 'invalid_username',
      :skip_email            => true
    )
    assert invited_account.errors[:username].present?

    assert !account.valid_password?('new_password')
  end

  should 'not confirm account on invite' do
    account = FactoryGirl.create(:account)
    account.invite!

    assert !account.confirmed?
  end

  should 'account.has_invitations_left? test' do
    # By default with invitation_limit nil, users can send unlimited invitations
    account = FactoryGirl.create(:account)
    assert account.invitation_limit == 5
    assert account.has_invitations_left?

    # With invitation_limit set to a value, all users can send that many invitations
    Account.stubs(:invitation_limit).returns(2)
    assert account.has_invitations_left?

    # With an individual invitation_limit of 0, a account shouldn't be able to send an invitation
    account.invitation_limit = 0
    assert account.save
    assert !account.has_invitations_left?

    # With in invitation_limit of 2, a account should be able to send two invitations
    account.invitation_limit = 2
    assert account.save
    assert account.has_invitations_left?
  end

  should 'not set the invited_by attribute if not passed' do
    account = FactoryGirl.create(:account)
    account.invite!
    assert account.invited_by.nil?
  end
 
  should 'set the invited_by attribute if passed' do
    account          = FactoryGirl.create(:account)
    inviting_account = FactoryGirl.create(:account)
    account.invite!(inviting_account)
    assert inviting_account.id == account.invited_by.id
    assert inviting_account.class.to_s == account.invited_by_type
  end
 
  should 'confirm account if confirmable' do
    account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org")
    account.accept_invitation!
 
    assert account.confirmed?
  end
 
  should 'not confirm account if validation fails' do
    Account.stubs(:invite_key).returns(:email => Revise.email_regexp, :username => /\A.+\z/)
    account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :username => 'invalid_username')
    account.accept_invitation!
 
    assert !account.confirmed?
  end
  
  should 'return instance with errors if invitation_token is nil' do
    registered_account = Account.create(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org", :password => '123456', :password_confirmation => '123456')
    account = Account.accept_invitation!
    assert !account.errors.empty?
  end

  should 'count accepted and not accepted invitations' do
    old_invitation_not_accepted_count = Account.invitation_not_accepted.count
    old_invitation_accepted_count     = Account.invitation_accepted.count

    Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org")
    account = Account.invite!(:email => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org")

    assert Account.invitation_not_accepted.count > old_invitation_not_accepted_count

    account.accept_invitation!
    assert Account.invitation_accepted.count > old_invitation_accepted_count
  end
end
