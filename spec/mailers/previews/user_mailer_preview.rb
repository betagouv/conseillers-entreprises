class UserMailerPreview < ActionMailer::Preview
  def match_feedback
    feedback = Feedback.category_need.sample
    UserMailer.match_feedback(feedback, feedback.need.experts.sample)
  end

  def quarterly_report
    UserMailer.quarterly_report(User.managers.sample)
  end
end
