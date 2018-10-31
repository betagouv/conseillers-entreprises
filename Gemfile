# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  if !repo_name.include?('/')
    repo_name = "#{repo_name}/#{repo_name}"
  end

  "https://github.com/#{repo_name}.git"
end

ruby '2.5.3'

gem 'rails'

# Server
gem 'foreman'
gem 'pg'
gem 'puma'

# Assets
gem 'coffee-rails'
gem 'compass-rails'
gem 'haml-rails'
gem 'jquery-rails'
gem 'sass-rails'
gem 'semantic-ui-sass'
gem 'uglifier'
gem 'premailer-rails'

# Parallel processes
gem 'clockwork'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'webpacker'

# Improving models
gem 'audited', '~> 4.5'
gem 'devise'
gem 'devise-async'
gem 'user_impersonate2', require: 'user_impersonate'

# Misc
gem 'activeadmin'
gem 'activeadmin-ajax_filter'
gem 'http'
gem 'jbuilder'
gem 'mailjet'
gem 'turbolinks'

# Notifiers
gem 'sentry-raven'

# Helper gems
gem 'browser'
gem 'metamagic'
gem 'wannabe_bool'

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'webmock'
end

group :development, :test do
  gem 'byebug', platform: :mri # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
end

group :development do
  gem 'awesome_print' # IRB console on exception pages or by using <%= console %>
  gem 'haml_lint', require: false
  gem 'i18n-tasks'
  gem 'listen'
  gem 'web-console'
  gem 'dotenv-rails'

  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'spring-commands-rspec'

  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# gem 'therubyracer', platforms: :ruby # See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'redis', '~> 3.0' # Use Redis adapter to run Action Cable in production
# gem 'bcrypt', '~> 3.1.7' # Use ActiveModel has_secure_password
# gem 'capistrano-rails', group: :development # Use Capistrano for deployment
