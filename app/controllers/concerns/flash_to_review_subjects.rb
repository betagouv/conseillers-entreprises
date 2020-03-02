module FlashToReviewSubjects
  extend ActiveSupport::Concern

  included do
    before_action :flash_to_review_subjects_if_needed, except: [:create, :update]
  end

  def flash_to_review_subjects_if_needed
    return unless user_signed_in?
    return unless current_user.can_view_review_subjects_flash
    return unless current_user.relevant_experts.any?(&:should_review_subjects?)

    expert_to_review = current_user.relevant_experts.find(&:should_review_subjects?)
    path = subjects_expert_path(expert_to_review)
    return if path == self.request.path

    if expert_to_review.team?
      message = I18n.t('experts.subjects_review.flash_team_html',
                       team: expert_to_review.full_name,
                       path: path)
    else
      message = I18n.t('experts.subjects_review.flash_html', path: path)
    end

    flash.now.notice = message.html_safe
  end
end
