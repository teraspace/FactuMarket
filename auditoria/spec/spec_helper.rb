ENV['RACK_ENV'] ||= 'test'

require 'rack/test'
require 'rspec'
require 'json'
require 'mongo'

ENV['MONGO_URI'] = 'mongodb://127.0.0.1:27017/auditoria_test'

require_relative '../interfaces/api'

Mongo::Logger.logger.level = Logger::FATAL

module AuditoriaSpecApp
  include Rack::Test::Methods

  def app
    Auditoria::Interfaces::API
  end
end

RSpec.configure do |config|
  config.include AuditoriaSpecApp

  config.before(:suite) do
    Auditoria::Interfaces::API.set :environment, :test
  end

  config.before do
    client = Auditoria::Infrastructure::Persistence::DatabaseConfig.mongo_client
    client[:events].delete_many({})
  end

  config.order = :random
  Kernel.srand config.seed
end
