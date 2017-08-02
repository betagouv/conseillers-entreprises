# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium-webdriver'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.include FactoryGirl::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.extend ControllerMacros, type: :controller
  config.extend FeatureMacros, type: :feature
  config.include Warden::Test::Helpers

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before :suite do
    # Run webpack compilation before suite, so assets exists in public/packs
    # see https://github.com/rspec/rspec-core/issues/2366
    # `bin/webpack`
    `env UV_THREADPOOL_SIZE=128 bin/webpack  -d --progress --verbose --display-reasons --display-chunks`
    # Webpacker::Manifest.load
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

Selenium::WebDriver.logger.level = :warn
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new app, browser: :chrome,
                                      options: Selenium::WebDriver::Chrome::Options.new(args: %w[headless disable-gpu])
end

Capybara.javascript_driver = :chrome
