# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'
  add_template_helper(Users::RegistrationsHelper)
  add_template_helper(UserMailerHelper)

  def send_new_user_invitation(user_params)
    @user_params = user_params

    mail(to: @user_params[:email], subject: t('mailers.user_mailer.send_new_user_invitation.subject'))
  end

  def account_approved(user)
    @user = user

    mail(to: @user.email, subject: t('mailers.user_mailer.account_approved.subject'))
  end

  def daily_change_update(user, change_updates)
    @user = user
    @change_updates = change_updates
    mail(to: @user.email, subject: t('mailers.user_mailer.daily_change_update.subject'))
  end

  def match_feedback(feedback)
    @feedback = feedback
    @author = feedback.match.person
    @need = feedback.match.need
    @persons = @need.contacted_persons - [@author]
    @advisor = @need.diagnosis.advisor
    @facility = @need.diagnosis.facility
    mail(to: @advisor.email_with_display_name,
         cc: @persons.map(&:email_with_display_name),
         reply_to: @author.email_with_display_name,
         subject: t('mailers.user_mailer.match_feedback.subject', company_name: @facility.company.name))
  end
end
