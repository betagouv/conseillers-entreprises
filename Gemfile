# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  if !repo_name.include?('/')
    repo_name = "#{repo_name}/#{repo_name}"
  end

  "https://github.com/#{repo_name}.git"
end

ruby '2.6.4'

gem 'rails'

# Server
gem 'foreman'
gem 'pg'
gem 'puma'

# Assets
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

# Improving models
gem 'audited', '~> 4.5'
gem 'devise'
gem 'devise-async'
gem 'user_impersonate2', require: 'user_impersonate'

# Charts
gem 'groupdate'
gem 'highcharts-rails'

# Misc
gem 'activeadmin'
gem 'activeadmin-ajax_filter'
gem 'http'
gem 'jbuilder'
gem 'mailjet'
gem 'turbolinks'
gem 'rails-i18n'

# Notifiers
gem 'sentry-raven'

# Helper gems
gem 'browser'
gem 'metamagic'
gem 'wannabe_bool'
gem 'active_link_to'

group :test do
  gem 'capybara'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'webmock'
  gem 'timecop'
end

group :development, :test do
  gem 'byebug', platform: :mri # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter', require: false
end

group :development do
  gem 'awesome_print'
  gem 'haml_lint', require: false
  gem 'i18n-tasks'
  gem 'web-console'
  gem 'dotenv-rails'
  gem 'therubyracer'
  gem 'annotate'

  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'spring-commands-rspec'

  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'brakeman', require: false
end

gem "debase", "~> 0.2.2"
