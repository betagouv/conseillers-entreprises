class CustomDeviseMailer < Devise::Mailer
  layout 'expert_mailers'

  def invitation_instructions(record, token, opts = {})
    if record.is_cooperation_manager?
      opts[:template_name] = 'invitation_instructions_cooperation_manager'

      @cooperation = record.managed_cooperations.first
      @cooperation_logo_name = @cooperation.logo&.filename
      @support_user = record.support_user

      opts[:subject] = I18n.t('devise.mailer.invitation_instructions_cooperation_manager.subject', cooperation: @cooperation.name)
      opts[:from] = email_address_with_name(ApplicationMailer::SENDER.call, @cooperation.support_user_name)
      opts[:reply_to] = @cooperation.support_user_email_with_name
    else
      @institution_logo_name = record.institution.logo&.filename
      @support_user = record.support_user

      opts[:subject] = I18n.t('devise.mailer.invitation_instructions.subject', institution: record.institution.name)
      opts[:from] = email_address_with_name(ApplicationMailer::SENDER.call, record.antenne.support_user_name)
      opts[:reply_to] = record.antenne.support_user_email_with_name
    end

    super
  end

  def reset_password_instructions(record, token, opts = {})
    @institution_logo_name = record.institution.logo&.filename
    @support_user = record.support_user
    super
  end
end
