# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} Admin <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/admin_mailer'

  def new_user_created_notification(user)
    @user = user

    recipients = default_recipients
    raise RecipientsExpectedError if recipients.empty?

    mail(to: recipients, subject: 'BIM ! Un matelot a rejoint l\'aventure !')
  end

  private

  def default_recipients
    User.where(is_admin: true).map(&:email) # TODO: Add [PROJECT_MAILING_LIST] when there is one
  end

  class RecipientsExpectedError < StandardError; end
end
