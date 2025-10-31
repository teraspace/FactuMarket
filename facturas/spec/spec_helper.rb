ENV['RACK_ENV'] ||= 'test'
ENV['SQLITE_PATH'] ||= ':memory:'
ENV['AUDITORIA_URL'] ||= 'http://auditoria.test:5003'

require 'rack/test'
require 'rspec'
require 'json'
require 'webmock/rspec'
require 'database_cleaner/active_record'

require_relative '../interfaces/api'

Dir[File.join(__dir__, 'support/**/*.rb')].sort.each { |file| require file }

WebMock.disable_net_connect!(allow_localhost: true)

module RSpecRackApp
  include Rack::Test::Methods

  def app
    Facturas::Interfaces::API
  end
end

RSpec.configure do |config|
  config.include RSpecRackApp

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
