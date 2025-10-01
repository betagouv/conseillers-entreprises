class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'
  helper :institutions

  layout 'expert_mailers'

  before_action :set_user_params
  before_deliver :filter_deleted_users

  def set_user_params
    @user = params[:user]
    throw :abort if @user.nil?

    @support_user = @user.support_user
    @institution_logo_name = @user.institution.logo&.filename
  end

  def filter_deleted_users
    throw :abort if @user.deleted?
  end

  def antenne_activity_report
    mail(
      to: @user.email_with_display_name,
      subject: t('mailers.user_mailer.antenne_activity_report.subject')
    )
  end

  def cooperation_activity_report
    @support_user = User.cooperations_referent.first
    @cooperation = @user.managed_cooperation
    return false if @support_user.nil? || @cooperation.nil?
    @cooperation_logo_name = @cooperation.logo&.filename

    mail(
      to: @user.email_with_display_name,
      subject: t('mailers.user_mailer.cooperation_activity_report.subject', cooperation: @cooperation.name)
    )
  end

  def invite_to_demo
    @expert_email = @user.first_expert_with_subject&.email
    return if @expert_email.nil?

    @demo_dates = DemoPlanning.new.call
    mail(
      to: @user.email_with_display_name,
      subject: t('mailers.user_mailer.invite_to_demo.subject')
    )
  end
end
