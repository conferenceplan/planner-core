ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../dummy/config/environment.rb',  __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'shoulda/matchers'
require 'capybara/webkit'
require 'capybara/rspec'
require 'capybara/rails'
require 'rspec/rails'
require 'factory_girl_rails'
require 'database_cleaner'

Capybara.javascript_driver = :webkit

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')

Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.infer_base_class_for_anonymous_controllers = false
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.order = 'random'

  config.include FactoryGirl::Syntax::Methods
  config.include Shoulda::Matchers
  config.include Warden::Test::Helpers

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation, except: %w(translations enumrecord))
    Warden.test_mode!
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation, {except: %w(translations enumrecord)}
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation, {except: %w(translations enumrecord)}
  end

  config.before(:each) do
    DatabaseCleaner.start
    FactoryGirl.create(:default_site_config)
    UISettingsService.setLanguages(['en', 'fr'])
  end

  config.after(:each) do
    Warden.test_reset!
    DatabaseCleaner.clean
  end
end

Capybara::Webkit.configure do |config|
  # Enable debug mode. Prints a log of everything the driver is doing.
  config.debug = false

  # By default, requests to outside domains (anything besides localhost) will
  # result in a warning. Several methods allow you to change this behavior.

  # Silently return an empty 200 response for any requests to unknown URLs.
  config.block_unknown_urls

  # Allow pages to make requests to any URL without issuing a warning.
  config.allow_unknown_urls

  # Allow a specific domain without issuing a warning.
  config.allow_url("example.com")

  # Allow a specific URL and path without issuing a warning.
  config.allow_url("example.com/some/path")

  # Wildcards are allowed in URL expressions.
  config.allow_url("*.example.com")

  # Silently return an empty 200 response for any requests to the given URL.
  config.block_url("example.com")

  # Timeout if requests take longer than 5 seconds
  config.timeout = 15

  # Don't raise errors when SSL certificates can't be validated
  config.ignore_ssl_errors

  # Don't load images
  config.skip_image_loading

  # Use a proxy
  # config.use_proxy(
  #   host: "example.com",
  #   port: 1234,
  #   user: "proxy",
  #   pass: "secret"
  # )
end