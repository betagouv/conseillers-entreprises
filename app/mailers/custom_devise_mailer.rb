class CustomDeviseMailer < Devise::Mailer
  def headers_for(action, opts)
    return super if action != :invitation_instructions
    super.merge!({
      subject: I18n.t('devise.mailer.invitation_instructions.subject', institution: resource.institution.name),
        from: email_address_with_name(ApplicationMailer::SENDER, resource.antenne.support_user_name),
        reply_to: resource.antenne.support_user_email_with_name
    })
  end
end
