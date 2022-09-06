# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'
  helper :institutions
  helper :status

  def match_feedback(feedback, person)
    @person = person
    return if @person.deleted? || feedback.nil?

    @feedback = feedback
    @author = feedback.user
    @match = person.received_matches.find_by(need: feedback.need.id)

    mail(to: @person.email_with_display_name,
         subject: t('mailers.user_mailer.match_feedback.subject', company_name: feedback.need.company))
  end

  def quarterly_report(user)
    @user = user

    mail(
      to: @user.email_with_display_name,
      subject: t('mailers.user_mailer.quarterly_report.subject')
    )
  end
end
