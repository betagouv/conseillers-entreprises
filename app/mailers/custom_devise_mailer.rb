class CustomDeviseMailer < Devise::Mailer
  layout 'expert_mailers'

  def headers_for(action, opts)
    if action == :invitation_instructions
      super.merge!({
        subject: invitation_instructions_subject(resource),
          from: email_address_with_name(ApplicationMailer::SENDER, resource_item.support_user_name),
          reply_to: resource_item.support_user_email_with_name
      })
    else
      super.merge!({
        from: ApplicationMailer::SENDER,
        reply_to: ApplicationMailer::REPLY_TO
      })
    end
  end

  def invitation_instructions(record, token, opts = {})
    if cooperation_invitation?(record)
      @cooperation = record.managed_cooperations.first
      @cooperation_logo_name = @cooperation.logo&.filename
    else
      @institution_logo_name = record.institution.logo&.filename
    end
    @support_user = record.support_user
    super
  end

  def reset_password_instructions(record, token, opts = {})
    @institution_logo_name = record.institution.logo&.filename
    @support_user = record.support_user
    super
  end

  private

  def cooperation_invitation?(resource)
    @cooperation_invitation ||= resource.managed_cooperations.any?
  end

  def invitation_instructions_subject(resource)
    if cooperation_invitation?(resource)
      I18n.t('devise.mailer.invitation_instructions.subject_cooperation', cooperation: resource_item.name)
    else
      I18n.t('devise.mailer.invitation_instructions.subject', institution: resource.institution.name)
    end
  end

  def resource_item
    if cooperation_invitation?(resource)
      resource.managed_cooperations.first
    else
      resource.antenne
    end
  end
end
