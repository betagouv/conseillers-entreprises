# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Reso
  class Application < Rails::Application
    config.time_zone = 'Paris'

    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = [:fr]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :fr

    config.action_mailer.default_url_options = { host: ENV['HOST_NAME'] }
    config.action_mailer.delivery_method = :mailjet
    config.active_job.queue_adapter = :delayed_job
  end
end
