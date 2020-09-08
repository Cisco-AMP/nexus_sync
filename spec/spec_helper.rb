require 'simplecov'
require 'pry'
require 'vcr'
require 'dotenv'

SimpleCov.start
Dotenv.load('.env.test')

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  VCR.configure do |config|
    config.allow_http_connections_when_no_cassette = true
    config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
end
