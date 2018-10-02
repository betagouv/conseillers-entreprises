class UserMailerPreview < ActionMailer::Preview
  def send_new_user_invitation
    UserMailer.send_new_user_invitation(user)
  end

  def account_approved
    UserMailer.account_approved(user)
  end

  def daily_change_update
    UserMailer.daily_change_update(user, Array.new(3) { change_hash })
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
      question_title: Faker::Lorem.sentence,
      company_name: Faker::Company.name,
      start_date: Date.yesterday,
      old_status: statuses.first,
      current_status: statuses.last,
    }
  end
end
