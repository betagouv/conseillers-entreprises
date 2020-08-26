# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  if repo_name.exclude?('/')
    repo_name = "#{repo_name}/#{repo_name}"
  end

  "https://github.com/#{repo_name}.git"
end

ruby '2.6.6'

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

# Parallel processes
gem 'clockwork'
gem 'daemons'
gem 'delayed_job_active_record'

# Improving models
gem 'audited'
gem 'devise'
gem 'devise-async'
gem 'devise_invitable'
gem 'user_impersonate2', require: 'user_impersonate'
gem 'pundit'

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
gem 'honeypot-captcha'
gem 'kaminari'
gem 'bootsnap', require: false
gem 'rails_autolink'
gem 'geocoder'

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
  gem 'axe-matchers', require: false
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
  gem "debase"
end

group :development do
  gem 'awesome_print'
  gem 'haml_lint', require: false
  gem 'i18n-tasks'
  gem 'listen'
  gem 'web-console'
  gem 'therubyracer'
  gem 'annotate'
  gem 'letter_opener_web'
  gem 'rails_real_favicon'
  gem 'pp_sql'

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
  gem "rails-erd"
end
