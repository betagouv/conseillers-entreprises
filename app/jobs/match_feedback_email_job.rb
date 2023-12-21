class MatchFeedbackEmailJob < ApplicationJob
  def perform(feedback_id, person)
    feedback = Feedback.find_by(id: feedback_id)
    if feedback.present?
      UserMailer.match_feedback(feedback, person).deliver_now
    end
  end
end
