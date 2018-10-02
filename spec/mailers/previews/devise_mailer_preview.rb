class DeviseMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    Devise::Mailer.confirmation_instructions(user, 'faketoken')
  end

  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(user, 'faketoken')
  end

  private

  def user
    FactoryBot.build(:user)
  end
end
