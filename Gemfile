# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.4.1'

gem 'rails', '~> 5.1.2'

# Server
gem 'foreman'
gem 'pg'
gem 'puma', '~> 3.0'

# Assets
gem 'coffee-rails', '~> 4.2'
gem 'compass-rails'
gem 'haml-rails', '~> 0.9'
gem 'jquery-rails'
gem 'sass-rails', '~> 5.0'
gem 'semantic-ui-sass', '~> 2'
gem 'uglifier', '>= 1.3.0'

# Parallel processes
gem 'clockwork', '~> 2.0', '>= 2.0.2'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'webpacker', '~> 2.0'

# Improving models
gem 'devise'
gem 'paranoia', '~> 2.2'
gem 'user_impersonate2', require: 'user_impersonate', github: 'rcook/user_impersonate2'

# Misc
gem 'activeadmin'
gem 'http'
gem 'jbuilder', '~> 2.5'
gem 'mailjet'
gem 'turbolinks', '~> 5'

# Notifiers
gem 'exception_notification'
gem 'slack-notifier'

# Helper gems
gem 'browser'
gem 'faker'
gem 'metamagic'
gem 'wannabe_bool'

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'webmock'
end

group :development, :test do
  gem 'byebug', platform: :mri # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'factory_girl_rails'
  gem 'rspec-rails', '~> 3.5'
end

group :development do
  gem 'awesome_print' # IRB console on exception pages or by using <%= console %>
  gem 'haml_lint', require: false
  gem 'i18n-tasks', '~> 0.9'
  gem 'listen', '~> 3.0.5'
  gem 'web-console', '>= 3.3.0'

  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# gem 'therubyracer', platforms: :ruby # See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'redis', '~> 3.0' # Use Redis adapter to run Action Cable in production
# gem 'bcrypt', '~> 3.1.7' # Use ActiveModel has_secure_password
# gem 'capistrano-rails', group: :development # Use Capistrano for deployment
