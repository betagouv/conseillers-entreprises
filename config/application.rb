require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PlaceDesEntreprises
  class Application < Rails::Application
    config.load_defaults 6.0

    config.time_zone = 'Paris'

    config.i18n.available_locales = [:fr]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :fr
    config.i18n.fallbacks = [I18n.default_locale]
    config.active_model.i18n_customize_full_message = true

    config.action_mailer.default_url_options = { host: ENV['HOST_NAME'] }

    config.active_job.queue_adapter = :delayed_job
    config.middleware.insert_after ActionDispatch::RemoteIp, IpAnonymizer::MaskIp
  end
end
