MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => logger)

case Padrino.env
  when :development then MongoMapper.database = 'revise_demo_app_development'
  when :production  then MongoMapper.database = 'revise_demo_app_production'
  when :test        then MongoMapper.database = 'revise_demo_app_test'
end