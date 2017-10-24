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

  def yesterday_modifications(user, yesterday_modifications)
    @user = user
    @yesterday_modifications = yesterday_modifications
    mail(to: @user.email, subject: t('mailers.user_mailer.yesterday_modifications.subject'))
  end
end
