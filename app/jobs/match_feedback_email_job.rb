class MatchFeedbackEmailJob < ApplicationJob
  def perform(feedback_id, person_id)
    feedback = Feedback.find_by(id: feedback_id)
    if feedback.present?
      user = User.find(person_id)
      UserMailer.match_feedback(feedback, user).deliver_now
    end
  end
end
