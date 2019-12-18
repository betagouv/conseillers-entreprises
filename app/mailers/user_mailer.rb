# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'
  add_template_helper(UserMailerHelper)

  def daily_change_update(user, change_updates)
    @user = user
    @change_updates = change_updates
    mail(to: @user.email, subject: t('mailers.user_mailer.daily_change_update.subject'))
  end

  def confirm_notifications_sent(diagnosis)
    @diagnosis = diagnosis
    @user = @diagnosis.advisor
    mail(to: @user.email_with_display_name,
      subject: t('mailers.user_mailer.confirm_notifications_sent.subject', company: @diagnosis.company.name, count: @diagnosis.needs.size))
  end

  def match_feedback(feedback)
    @feedback = feedback
    @advisor = feedback.need.diagnosis.advisor
    @author = feedback.author
    mail(to: @advisor.email_with_display_name,
         reply_to: @author.email_with_display_name,
         subject: t('mailers.user_mailer.match_feedback.subject', company: feedback.need.company))
  end

  def update_match_notify(match, user, previous_status)
    @status = {}
    @match = match
    @expert = match.expert
    @previous_status = previous_status
    @user = user
    @advisor = match.advisor
    @company = match.company
    @need = match.need
    @subject = match.subject
    mail(to: @advisor.email, subject: t('mailers.user_mailer.update_match_notify.subject', company_name: @company.name))
  end
end
