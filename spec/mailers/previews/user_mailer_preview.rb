class UserMailerPreview < ActionMailer::Preview
  def match_feedback
    feedback = Feedback.category_need.sample
    UserMailer.match_feedback(feedback, feedback.need.experts.sample)
  end

  def notify_match_status
    UserMailer.notify_match_status(Match.all.sample, Match.all.sample.status)
  end

  def quarterly_report
    UserMailer.quarterly_report(User.managers.sample)
  end
end
