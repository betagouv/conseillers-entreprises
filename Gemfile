# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.4.1'

gem 'coffee-rails', '~> 4.2'
gem 'foreman'
gem 'haml-rails', '~> 0.9'
gem 'pg'
gem 'puma', '~> 3.0'
gem 'rails', '~> 5.1.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

gem 'activeadmin'
gem 'devise'
gem 'faker'
gem 'mailjet'

gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'

gem 'semantic-ui-sass', '~> 2'

gem 'i18n-tasks', '~> 0.8.3'
gem 'wannabe_bool'

gem 'capybara'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :test do
  gem 'shoulda-matchers', '~> 3.1'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'factory_girl_rails'
  gem 'rspec-rails', '~> 3.5'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.0.5'
  gem 'web-console', '>= 3.3.0'
  gem 'awesome_print'

  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
