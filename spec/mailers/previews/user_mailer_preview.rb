class UserMailerPreview < ActionMailer::Preview
  def antenne_activity_report
    UserMailer.with(user: User.active.managers.sample).antenne_activity_report
  end

  def cooperation_activity_report
    UserMailer.with(user: User.active.cooperation_managers.sample).cooperation_activity_report
  end

  def invite_to_demo
    UserMailer.with(user: User.active.joins(:experts).merge(Expert.not_deleted.with_subjects).sample).invite_to_demo
  end
end
