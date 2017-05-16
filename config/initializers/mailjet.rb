# frozen_string_literal: true

Mailjet.configure do |config|
  config.api_key = ENV['MAILJET_API_PUBLIC_KEY']
  config.secret_key = ENV['MAILJET_API_SECRET_KEY']
  config.default_from = ENV['APPLICATION_EMAIL']
end
