class UserMailerPreview < ActionMailer::Preview
  def confirm_notifications_sent
    UserMailer.confirm_notifications_sent(Diagnosis.completed.sample)
  end

  def match_feedback
    feedback = Feedback.all.sample
    UserMailer.match_feedback(feedback, feedback.need.experts.sample)
  end

  def notify_match_status
    UserMailer.notify_match_status(Match.all.sample, Match.all.sample.status)
  end

  def remind_invitation
    UserMailer.remind_invitation(User.not_deleted.sample)
  end
end
