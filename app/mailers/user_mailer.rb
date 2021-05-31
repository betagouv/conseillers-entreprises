# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'
  helper :institutions

  def confirm_notifications_sent(diagnosis)
    @diagnosis = diagnosis
    @user = @diagnosis.advisor
    mail(to: @user.email_with_display_name,
      subject: t('mailers.user_mailer.confirm_notifications_sent.subject', company: @diagnosis.company.name, count: @diagnosis.needs.size))
  end

  def match_feedback(feedback, person)
    @feedback = feedback
    @person = person
    @author = feedback.user

    return if @person.deleted?
    mail(to: @person.email_with_display_name,
         reply_to: @author.email_with_display_name,
         subject: t('mailers.user_mailer.match_feedback.subject', company_name: feedback.need.company))
  end

  def notify_match_status(match, previous_status)
    @status = {}
    @match = match
    @expert = match.expert
    @previous_status = previous_status
    @advisor = match.advisor
    @company = match.company
    @need = match.need
    @subject = match.subject

    return if (@advisor.deleted? || @advisor.is_admin)
    mail(to: @advisor.email, subject: t('mailers.user_mailer.notify_match_status.subject', company_name: @company.name))
  end

  def remind_invitation(user)
    @user = user
    @institution = user.institution
    @token = @user.invitation_token

    mail(to: @user.email, subject: t('mailers.user_mailer.remind_invitation.subject', institution_name: @institution.name))
  end
end
