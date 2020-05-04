# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'

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
    return if @person.is_a?(User) && @person.deleted? # TODO remove the is_a? after #991
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
    return if @advisor.deleted?
    mail(to: @advisor.email, subject: t('mailers.user_mailer.notify_match_status.subject', company_name: @company.name))
  end
end
