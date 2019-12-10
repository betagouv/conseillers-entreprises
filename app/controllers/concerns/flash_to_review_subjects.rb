module FlashToReviewSubjects
  extend ActiveSupport::Concern

  included do
    before_action :flash_to_review_subjects_if_needed, only: [:index, :show]
  end

  def flash_to_review_subjects_if_needed
    expert_to_review = current_user.experts.find(&:should_review_subjects?)
    if expert_to_review.present?
      message = I18n.t('experts.flash.review_your_subjects_html',
                       antenne: expert_to_review.antenne,
                       edit_expert_path: edit_expert_path(expert_to_review))
      flash.now.notice = message.html_safe
    end
  end
end
