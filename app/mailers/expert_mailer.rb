# frozen_string_literal: true

class ExpertMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/expert_mailer'

  def notify_company_needs(expert, params)
    @access_token = expert.access_token
    @params = params

    mail(
      to: "#{expert.full_name} <#{expert.email}>",
      cc: "#{params[:advisor].full_name} <#{params[:advisor].email}>",
      subject: t('mailers.expert_mailer.notify_company_needs.subject', company_name: params[:company_name])
    )
  end

  def remind_involvement(expert, selected_assistances_experts_hash)
    @access_token = expert.access_token
    @selected_assistances_experts_hash = selected_assistances_experts_hash

    mail(
      to: "#{expert.full_name} <#{expert.email}>",
      subject: t('mailers.expert_mailer.remind_involvement.subject')
    )
  end
end
