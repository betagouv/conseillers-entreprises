class DeviseMailerPreview < ActionMailer::Preview
  def invitation_instructions
    user = User.all.sample
    user.inviter = User.all.sample
    Devise::Mailer::invitation_instructions(user, 'faketoken')
  end

  def confirmation_instructions
    Devise::Mailer.confirmation_instructions(user, 'faketoken')
  end

  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(user, 'faketoken')
  end

  private

  def user
    User.all.sample
  end
end
