namespace :db do 
  task :empty => :environment do  
    # Don't run this if the environment is production
    # Emptying the DB of production data would be bad
    unless Padrino.env == :production
      puts 'Removing All Accounts'
      Account.all.each { |a| a.destroy }
    end
  end
end
