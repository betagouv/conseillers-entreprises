# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  if repo_name.exclude?('/')
    repo_name = "#{repo_name}/#{repo_name}"
  end

  "https://github.com/#{repo_name}.git"
end

ruby '3.0.2'

gem 'rails'

# Server
gem 'foreman'
gem 'pg'
gem 'puma'

# Assets
gem 'haml-rails'
gem 'jquery-rails'
gem 'sassc-rails'
gem 'fomantic-ui-sass'
gem 'uglifier'
gem 'premailer-rails'
gem 'css_parser'
gem 'webpacker'

# Parallel processes
gem 'clockwork'
gem 'daemons'
gem 'delayed_job_active_record'

# Improving models
gem 'devise'
gem 'devise-async'
gem 'devise_invitable'
gem 'user_impersonate2', require: 'user_impersonate'
gem 'pundit'
gem 'activerecord-postgres_enum'
gem 'auto_strip_attributes'
gem 'acts_as_list'

# Charts
gem 'highcharts-rails'

# Misc
gem 'activeadmin'
gem 'activeadmin-ajax_filter'
gem 'activeadmin_blaze_theme'
gem 'activeadmin_quill_editor'
gem 'http'
gem 'jbuilder'
gem 'turbolinks'
gem 'rails-i18n'
gem 'honeypot-captcha'
gem 'kaminari'
gem 'bootsnap', require: false
gem 'rails_autolink'
gem 'geocoder'
gem 'sib-api-v3-sdk', '~> 7.2'
gem 'recipient_interceptor'
gem 'ip_anonymizer'
gem 'highline'
gem 'caxlsx'
gem 'caxlsx_rails'

# Notifiers
gem "sentry-ruby"
gem "sentry-rails"
gem "sentry-delayed_job"

# Helper gems
gem 'browser'
gem 'metamagic'
gem 'wannabe_bool'
gem 'active_link_to'

# Security
gem 'rack-attack'

# Performance
gem 'scout_apm'

group :test do
  gem 'capybara'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'webmock'
  gem 'axe-matchers', require: false
  gem 'simplecov', require: false
  gem 'rspec-retry'
end

group :development, :test do
  gem 'byebug', platform: :mri # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter', require: false
  gem 'parallel_tests'
  gem 'spring-commands-parallel-tests'
  gem "dotenv-rails"
  gem 'w3c_validators', require: false
end

group :development do
  gem 'awesome_print'
  gem 'haml_lint', require: false
  gem 'i18n-tasks'
  gem 'listen'
  gem 'web-console'
  gem 'annotate'
  gem 'letter_opener_web'
  gem 'rails_real_favicon'
  gem 'pp_sql'
  gem 'bullet'

  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'spring-commands-rspec'

  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-faker', require: false
  gem 'rubocop-i18n', require: false
  gem 'brakeman', require: false
  gem "rails-erd", git: 'https://github.com/andrew-newell/rails-erd' # Compatibility for Rails 6.1, until https://github.com/voormedia/rails-erd/pull/365 is merged.
end
