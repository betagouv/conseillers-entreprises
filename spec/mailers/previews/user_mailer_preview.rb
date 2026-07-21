class UserMailerPreview < ActionMailer::Preview
  def antenne_activity_report
    UserMailer.with(user: User.active.managers.find_random).antenne_activity_report
  end

  def cooperation_activity_report
    user = User.active.cooperation_managers.find_random
    UserMailer.with(user: user, cooperation: user.managed_cooperations.find_random).cooperation_activity_report
  end

  def invite_to_demo
    UserMailer.with(user: User.active.joins(:experts).merge(Expert.not_deleted.with_subjects).find_random).invite_to_demo
  end
end
