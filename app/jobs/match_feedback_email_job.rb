class MatchFeedbackEmailJob < ApplicationJob
  def perform(feedback, person)
    if feedback.present?
      UserMailer.match_feedback(feedback, person).deliver_now
    end
  end
end
