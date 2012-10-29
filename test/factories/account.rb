FactoryGirl.define do
  factory :account do
    email { "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org" }
    username { Faker::Internet.user_name + "_#{rand(0...1000)}" }
    password 'testpass'
    password_confirmation 'testpass'
    name { Faker::Name.name }
    skip_email true
    role :test
  end

  factory :account_admin, :parent => :account do 
    role :admin
  end
end
