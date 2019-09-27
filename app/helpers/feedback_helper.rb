module FeedbackHelper
  def need_feedback_author_hidden_field(need, current_roles)
    current_expert_for_need = need.experts.where(id: current_roles).first
    if current_expert_for_need.present?
      [:expert_id, value: current_expert_for_need.id]
    elsif need.advisor == current_user
      [:user_id, value: current_user.id]
    end
  end
end
