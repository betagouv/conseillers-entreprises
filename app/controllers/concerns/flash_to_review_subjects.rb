module FlashToReviewSubjects
  extend ActiveSupport::Concern

  included do
    before_action :flash_to_review_subjects_if_needed, only: [:index, :show]
  end

  def flash_to_review_subjects_if_needed
    if current_user.can_view_review_subjects_flash &&
      current_user.experts.any?(&:should_review_subjects?)
      message = I18n.t('experts.flash.review_your_subjects_html',
                       antenne: expert_to_review.antenne,
                       edit_expert_path: edit_expert_path(expert_to_review))
      flash.now.notice = message.html_safe
    end
  end
end
