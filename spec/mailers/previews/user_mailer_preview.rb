class UserMailerPreview < ActionMailer::Preview
  def quarterly_report
    UserMailer.with(user: User.active.managers.sample).quarterly_report
  end

  def invite_to_demo
    UserMailer.with(user: User.active.sample).invite_to_demo
  end
end
