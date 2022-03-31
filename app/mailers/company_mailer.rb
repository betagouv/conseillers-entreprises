# frozen_string_literal: true

class CompanyMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/company_mailer'

  def confirmation_solicitation(solicitation)
    @solicitation = solicitation
    mail(
      to: @solicitation.email,
      subject: t('mailers.company_mailer.confirmation_solicitation.subject')
    )
  end

  def notify_taking_care(match)
    @match = match
    @diagnosis = match.diagnosis
    mail(
      to: @diagnosis.visitee.email_with_display_name,
      subject: t('mailers.company_mailer.notify_taking_care.subject')
    )
  end

  def notify_not_reachable(match)
    @match = match
    @diagnosis = match.diagnosis
    mail(
      to: @diagnosis.visitee.email_with_display_name,
      subject: t('mailers.company_mailer.notify_not_reachable.subject')
    )
  end

  def satisfaction(need)
    @need = need
    @email_token = Digest::SHA256.hexdigest(@need.diagnosis.visitee.email)
    mail(
      to: @need.diagnosis.visitee.email_with_display_name,
      subject: t('mailers.company_mailer.satisfaction.subject')
    )
  end

  def retention(need)
    @need = need

    mail(
      to: @need.diagnosis.visitee.email_with_display_name,
      subject: t('mailers.company_mailer.retention.subject')
    )
  end

  def abandoned_need(need)
    @need = need

    mail(to: @need.diagnosis.visitee.email, subject: t('mailers.company_mailer.abandoned_need.subject'))
  end
end
