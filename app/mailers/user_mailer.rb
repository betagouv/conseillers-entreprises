# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'
  add_template_helper(Users::RegistrationsHelper)

  def send_new_user_invitation(user_params)
    @user_params = user_params

    mail(to: @user_params[:email], subject: t('mailers.user_mailer.send_new_user_invitation.subject'))
  end
end
