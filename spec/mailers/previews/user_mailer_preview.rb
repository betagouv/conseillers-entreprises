class UserMailerPreview < ActionMailer::Preview
  def quarterly_report
    UserMailer.with(user: User.active.managers.sample).quarterly_report
  end
end
