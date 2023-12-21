class MatchFeedbackEmailJob < ApplicationJob
  def perform(feedback_id, expert_id)
    feedback = Feedback.find_by(id: feedback_id)
    if feedback.present?
      expert = Expert.find(expert_id)
      UserMailer.match_feedback(feedback, expert).deliver_now
    end
  end
end
