class UserMailerPreview < ActionMailer::Preview
  def confirm_notifications_sent
    UserMailer.confirm_notifications_sent(Diagnosis.completed.sample)
  end

  def match_feedback
    feedback = Feedback.all.sample
    UserMailer.match_feedback(feedback, feedback.need.advisor)
  end

  def update_match_notify
    UserMailer.update_match_notify(Match.all.sample, User.all.sample, Match.all.sample.status)
  end
end
