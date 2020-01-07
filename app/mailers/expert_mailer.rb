# frozen_string_literal: true

class ExpertMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/expert_mailer'

  def notify_company_needs(expert, diagnosis)
    @expert = expert
    @diagnosis = diagnosis

    mail(
      to: @expert.email_with_display_name,
      subject: t('mailers.expert_mailer.notify_company_needs.subject', company_name: @diagnosis.company.name)
    )
  end

  def remind_involvement(expert)
    @expert = expert

    @needs_quo = expert.needs_quo
    @needs_taking_care = expert.needs_taking_care
    @needs_others_taking_care = expert.needs_others_taking_care

    return if @needs_taking_care.empty? && @needs_quo.empty? && @needs_others_taking_care.empty?

    mail(
      to: @expert.email_with_display_name,
      subject: t('mailers.expert_mailer.remind_involvement.subject')
    )
  end
end
