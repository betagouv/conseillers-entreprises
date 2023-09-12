class DeviseMailerPreview < ActionMailer::Preview
  def invitation_instructions
    user = User.not_deleted.sample
    user.inviter = User.all.sample
    CustomDeviseMailer.invitation_instructions(user, 'faketoken')
  end

  def reset_password_instructions
    user = User.not_deleted.sample
    user.reset_password_sent_at = Time.now.utc
    CustomDeviseMailer.reset_password_instructions(user, 'faketoken')
  end

  def reset_password_instructions_never_used
    user = User.not_deleted.sample
    user.invitation_accepted_at = nil
    CustomDeviseMailer.reset_password_instructions(user, 'faketoken')
  end

  # Other Devise emails never used:
  # confirmation_instructions: Signup is invite-only, and we don’t let users change their email themselves. If we allow it, we’ll use send_reconfirmation_instructions.
  # email_changed: config.send_email_change_notification is false
  # password_change: config.send_password_change_notification is false
  # unlock_instructions: User is not :lockable.
end
