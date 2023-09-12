# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  SENDER_EMAIL = ENV['APPLICATION_MARKETING_EMAIL']
  REPLY_TO_EMAIL = ENV['APPLICATION_EMAIL']
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  REPLY_TO = "#{I18n.t('app_name')} <#{REPLY_TO_EMAIL}>"
  default from: SENDER, reply_to: REPLY_TO
  helper :mailto

  layout 'mailers'
end
