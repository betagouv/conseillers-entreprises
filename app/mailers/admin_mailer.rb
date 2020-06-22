# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} Admin <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/admin_mailer'

  helper :solicitation

  def weekly_statistics(information_hash)
    @information_hash = information_hash

    mail(to: default_recipients, subject: t('mailers.admin_mailer.weekly_statistics.subject'))
  end

  def solicitation(solicitation)
    @solicitation = solicitation
    mail(to: default_recipients, subject: t('mailers.admin_mailer.solicitation.subject'))
  end

  def send_csv(model, file, user)
    @model_name = model.constantize.model_name.human.pluralize
    file_name = file.path.split('/').last
    attachments[file_name] = File.read(file.path)
    mail(to: user.email, subject: t('mailers.admin_mailer.csv_export', model: @model_name), attachments: attachments)
  end

  private

  def default_recipients
    ENV['APPLICATION_EMAIL']
  end
end
