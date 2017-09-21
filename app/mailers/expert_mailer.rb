# frozen_string_literal: true

class ExpertMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/expert_mailer'

  def notify_company_needs(expert, params)
    @params = params
    @access_token = expert.access_token

    mail(
      to: "#{expert.full_name} <#{expert.email}>",
      cc: "#{params[:advisor].full_name} <#{params[:advisor].email}>",
      subject: t('mailers.expert_mailer.notify_company_needs.subject', company_name: params[:company_name])
    )
  end
end
