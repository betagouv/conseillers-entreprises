# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} Admin <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/admin_mailer'

  helper :solicitation

  def new_user_approved_notification(user, admin)
    @user = user
    @admin = admin

    subject = t('mailers.admin_mailer.new_user_approved_notification.subject', full_name: @user.full_name)
    mail(to: default_recipients, subject: subject)
  end

  def weekly_statistics(information_hash)
    @information_hash = information_hash

    mail(to: default_recipients, subject: t('mailers.admin_mailer.weekly_statistics.subject'))
  end

  def solicitation(solicitation)
    @solicitation = solicitation
    mail(to: default_recipients, subject: t('mailers.admin_mailer.solicitation.subject'))
  end

  private

  def default_recipients
    ENV['APPLICATION_EMAIL']
  end
end
