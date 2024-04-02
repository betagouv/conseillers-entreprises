# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'system_helper'
require 'sidekiq/testing'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = Rails.root.join('spec', 'fixtures')
  config.use_transactional_fixtures = true

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::ControllerHelpers, type: :helper
  config.extend ControllerMacros, type: :controller
  config.extend ControllerMacros, type: :view
  config.extend ControllerMacros, type: :helper
  config.extend FeatureMacros, type: :feature
  config.extend FeatureMacros, type: :system
  config.include Warden::Test::Helpers
  config.include PunditSpecHelper, type: :view
  config.include ApiSpecHelper, type: :request
  config.include SplitHelper
  config.extend RemindersSpecHelper
  config.include ActiveJob::TestHelper

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    if ENV["SELENIUM_DRIVER_URL"].present?
      driven_by :selenium, using: :chrome,
        options: {
          browser: :remote,
          url: ENV.fetch("SELENIUM_DRIVER_URL"),
          desired_capabilities: :chrome
        }
    else
      driven_by :selenium_chrome_headless
    end
  end

  # les tests ont besoin des seeds pour les régions deployées
  config.before(:suite) do
    Rails.application.load_seed
  end

  config.before(type: :job) do
    Sidekiq::ScheduledSet.new.clear
    Sidekiq::Testing.disable!
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
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[headless disable-gpu])
  browser_path = ENV['DEVELOPMENT_SELENIUM_CHROMIUM_BROWSER_PATH']
  options.binary = browser_path if browser_path.present?
  Capybara::Selenium::Driver.new app, browser: :chrome, options: options
end

Capybara.javascript_driver = :chrome
Capybara.default_max_wait_time = 5
WebMock.disable_net_connect!(allow_localhost: true)

RSpec::Sidekiq.configure do |config|
  config.warn_when_jobs_not_processed_by_sidekiq = false
end
