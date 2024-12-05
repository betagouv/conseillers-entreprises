# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'
  helper :institutions
  helper :status

  layout 'expert_mailers'

  def quarterly_report
    with_user_init do
      mail(
        to: @user.email_with_display_name,
        subject: t('mailers.user_mailer.quarterly_report.subject')
      )
    end
  end

  private

  def with_user_init
    @user = params[:user]
    return false if @user.nil? || @user.deleted?
    @support_user = @user.support_user
    @institution_logo_name = @user.institution.logo&.filename
    yield
  end
end
