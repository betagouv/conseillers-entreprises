# frozen_string_literal: true

class CompanyMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/company_mailer'

  def confirmation_solicitation(email)
    mail(
      to: email,
      subject: t('mailers.company_mailer.confirmation_solicitation.subject')
    )
  end

  def notify_matches_made(diagnosis)
    @diagnosis = diagnosis

    subject = @diagnosis.from_solicitation? ?
      t('mailers.company_mailer.notify_matches_made.subject_from_solicitation') :
      t('mailers.company_mailer.notify_matches_made.subject_from_visit')
    mail(
      to: @diagnosis.visitee.email_with_display_name,
      subject: subject
    )
  end

  def notify_taking_care(match)
    @match = match
    @need = match.need
    @advisor = match.advisor
    @expert = match.expert
    mail(
      to: @match.diagnosis.visitee.email_with_display_name,
      subject: t('mailers.company_mailer.notify_taking_care.subject')
    )
  end
end
