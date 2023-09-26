# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'
  helper :institutions
  helper :status

  layout 'expert_mailers'

  before_action :set_user

  def match_feedback
    @feedback = params[:feedback]
    return if @feedback.nil?

    @author = @feedback.user
    @match = @user.received_matches.find_by(need: @feedback.need.id)

    mail(to: @user.email_with_display_name,
         subject: t('mailers.user_mailer.match_feedback.subject', company_name: @feedback.need.company))
  end

  def quarterly_report
    mail(
      to: @user.email_with_display_name,
      subject: t('mailers.user_mailer.quarterly_report.subject')
    )
  end

  private

  def set_user
    @user = params[:user]
    return if @user.deleted?
    @institution_logo_name = @user.institution.logo&.filename
  end
end
