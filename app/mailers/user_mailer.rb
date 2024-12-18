# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'
  helper :institutions

  layout 'expert_mailers'

  def quarterly_report
    with_user_init do
      mail(
        to: @user.email_with_display_name,
        subject: t('mailers.user_mailer.quarterly_report.subject')
      )
    end
  end

  def invite_to_demo
    with_user_init do
      @expert_email = @user.first_expert_with_subject&.email
      return if @expert_email.nil?

      @demo_dates = DemoPlanning.new.call
      mail(
        to: @user.email_with_display_name,
        subject: t('mailers.user_mailer.invite_to_demo.subject')
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
