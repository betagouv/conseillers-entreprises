class UserMailerPreview < ActionMailer::Preview
  def daily_change_update
    UserMailer.daily_change_update(user, Array.new(3) { change_hash })
  end

  def confirm_notifications_sent
    UserMailer.confirm_notifications_sent(Diagnosis.completed.sample)
  end

  def match_feedback
    UserMailer.match_feedback(Feedback.all.sample)
  end

  private

  def user
    User.all.sample
  end

  def change_hash
    statuses = Match.statuses.keys.sample(2)
    {
      expert_name: Faker::Name.name,
      expert_institution: Faker::Company.name,
      subject_title: Faker::Lorem.sentence,
      company_name: Faker::Company.name,
      start_date: Date.yesterday,
      old_status: statuses.first,
      current_status: statuses.last,
    }
  end
end
