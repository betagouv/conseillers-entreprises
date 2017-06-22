# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} Admin <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/admin_mailer'

  def new_user_created_notification(user)
    @user = user

    mail(to: default_recipients, subject: 'BIM ! Un matelot a rejoint l\'aventure !')
  end

  private

  def default_recipients
    ENV['APPLICATION_EMAIL']
  end
end
