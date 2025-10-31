RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.allow_production = false
    DatabaseCleaner[:active_record].clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner[:active_record].strategy = :truncation
    DatabaseCleaner[:active_record].cleaning do
      example.run
    end
  end
end
