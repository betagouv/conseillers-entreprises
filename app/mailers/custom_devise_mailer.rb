class CustomDeviseMailer < Devise::Mailer
  layout 'expert_mailers'

  def invitation_instructions(record, token, opts = {})
    if record.is_sponsor?
      opts[:template_name] = 'invitation_instructions_sponsor'

      @antenne = record.antenne
      @institution_logo_name = record.institution.logo&.filename

      opts[:subject] = I18n.t('devise.mailer.invitation_instructions_sponsor.subject')
    elsif record.is_cooperation_manager?
      opts[:template_name] = 'invitation_instructions_cooperation_manager'

      @cooperation = record.managed_cooperations.first
      @cooperation_logo_name = @cooperation.logo&.filename

      opts[:subject] = I18n.t('devise.mailer.invitation_instructions_cooperation_manager.subject', cooperation: @cooperation.name)
    else
      @institution_logo_name = record.institution.logo&.filename

      opts[:subject] = I18n.t('devise.mailer.invitation_instructions.subject', institution: record.institution.name)
    end

    @support_user = record.support_user
    full_name_with_suffix = [@support_user.full_name, I18n.t('app_name')].compact.join(" - ")
    opts[:from] = email_address_with_name(ApplicationMailer::SENDER.call, full_name_with_suffix)
    opts[:reply_to] = email_address_with_name(@support_user.email, full_name_with_suffix)

    super
  end

  def reset_password_instructions(record, token, opts = {})
    @institution_logo_name = record.institution.logo&.filename
    @support_user = record.support_user
    super
  end
end
