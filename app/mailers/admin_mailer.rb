# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} Admin <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/admin_mailer'

  helper :solicitation

  def failed_jobs(jobs_count)
    @jobs_count = jobs_count

    mail(subject: t('mailers.admin_mailer.failed_jobs.subject', count: @jobs_count))
  end

  def solicitation(solicitation)
    @solicitation = solicitation
    mail(subject: t('mailers.admin_mailer.solicitation.subject'))
  end

  def send_csv(model, ransack_params, file, user)
    @model_name = model.constantize.model_name.human.pluralize
    @ransack_params = ransack_params
    file_name = file.path.split('/').last
    attachments[file_name] = File.read(file.path)
    mail(subject: t('mailers.admin_mailer.csv_export', model: @model_name))
  end

  private

  def default_recipients
    ENV['APPLICATION_EMAIL']
  end
end
