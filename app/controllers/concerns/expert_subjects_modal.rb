# frozen_string_literal: true

module ExpertSubjectsModal
  # Display a “review subjects” modal on top of the UI, in certain conditions
  def maybe_review_expert_subjects
    return unless user_signed_in?
    return unless current_user.can_view_review_subjects_flash # technically, not a “flash”, but we’ll remove it at some point
    return unless current_user.relevant_experts.any?(&:should_review_subjects?)

    expert = current_user.relevant_experts.find(&:should_review_subjects?)
    @app_modal = {
      partial: 'experts/subjects_modal',
      locals: { expert: expert }
    }
  end
end
