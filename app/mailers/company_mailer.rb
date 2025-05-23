# frozen_string_literal: true

class CompanyMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/company_mailer'

  helper :solicitation, :images

  def confirmation_solicitation(solicitation)
    @solicitation = solicitation
    @cooperation_logo_name = cooperation_logo_name
    mail(
      to: @solicitation.email,
      subject: t('mailers.company_mailer.confirmation_solicitation.subject', subject: solicitation.final_subject_title)
    )
  end

  def notify_taking_care(match)
    @match = match
    @diagnosis = match.diagnosis
    @subject_title = @diagnosis.subject_title
    # Cas des vieilles données effacées
    if @diagnosis.visitee.email.present?
      mail(
        to: @diagnosis.visitee.email_with_display_name,
        subject: t('mailers.company_mailer.notify_taking_care.subject', subject: @subject_title)
      )
    end
  end

  def notify_not_reachable(match)
    @match = match
    @diagnosis = match.diagnosis
    @subject_title = @diagnosis.subject_title
    mail(
      to: @diagnosis.visitee.email_with_display_name,
      subject: t('mailers.company_mailer.notify_not_reachable.subject', subject: @subject_title)
    )
  end

  def satisfaction(need)
    @need = need
    @email_token = Digest::SHA256.hexdigest(@need.diagnosis.visitee.email)
    mail(
      to: @need.diagnosis.visitee.email_with_display_name,
      subject: t('mailers.company_mailer.satisfaction.subject', subject: @need.subject.label)
    )
  end

  def retention(need)
    @need = need

    mail(
      to: @need.diagnosis.visitee.email_with_display_name,
      subject: t('mailers.company_mailer.retention.subject')
    )
  end

  def failed_need(need)
    @need = need

    mail(to: @need.diagnosis.visitee.email, subject: t('mailers.company_mailer.failed_need.subject'))
  end

  def solicitation_relaunch_company(solicitation)
    @solicitation = solicitation
    @cooperation_logo_name = cooperation_logo_name
    mail(to: @solicitation.email, subject: t('mailers.company_mailer.solicitation_relaunch_company.subject', subject: solicitation.final_subject_title))
  end

  def solicitation_relaunch_description(solicitation)
    @solicitation = solicitation
    @cooperation_logo_name = cooperation_logo_name
    mail(to: @solicitation.email, subject: t('mailers.company_mailer.solicitation_relaunch_description.subject', subject: solicitation.final_subject_title))
  end

  def intelligent_retention(need, email_retention)
    @need = need
    @email_retention = email_retention

    mail(to: @need.solicitation.email, subject: @email_retention.email_subject)
  end

  def not_yet_taken_care(solicitation)
    @solicitation = solicitation
    mail(to: @solicitation.email, subject: t('mailers.company_mailer.not_yet_taken_care.subject', subject: solicitation.final_subject_title))
  end

  private

  def cooperation_logo_name
    @solicitation.cooperation&.logo&.filename
  end
end
