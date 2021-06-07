class CustomDeviseMailer < Devise::Mailer
  def headers_for(action, opts)
    return super if action != :invitation_instructions
    super.merge!(
      { subject: I18n.t('devise.mailer.invitation_instructions.subject', institution: resource.institution.name),
        from: resource.antenne.user_support_email})
  end
end
