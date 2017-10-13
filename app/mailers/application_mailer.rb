# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  SENDER_EMAIL = ENV['APPLICATION_EMAIL']
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER

  layout 'mailer'
end
