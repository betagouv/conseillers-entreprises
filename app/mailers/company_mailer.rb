# frozen_string_literal: true

class CompanyMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/company_mailer'

  def confirmation_solicitation(email)
    mail(
      to: email,
      subject: t('mailers.company_mailer.confirmation_solicitation.subject'),
      reply_to: SENDER
    )
  end

  def taking_care_by_expert(match)
    @match = match
    @need = match.need
    @advisor = match.advisor
    @expert = match.expert
    mail(
      to: @match.diagnosis.visitee.email,
      subject: t('mailers.company_mailer.taking_care_by_expert.subject'),
      reply_to: SENDER
    )
  end
end
