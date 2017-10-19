# frozen_string_literal: true

class SelectedAssistanceExpertValidator < ActiveModel::Validator
  def validate(selected_assistance_expert)
    return nil unless selected_assistance_expert.assistance_expert && selected_assistance_expert.territory_user
    selected_assistance_expert.errors.add(:assistance_expert, :can_not_be_set_with_territory_user)
  end
end

class SelectedAssistanceExpert < ApplicationRecord
  enum status: { quo: 0, taking_care: 1, done: 2, not_for_me: 3 }, _prefix: true

  belongs_to :diagnosed_need
  belongs_to :assistance_expert, foreign_key: :assistances_experts_id
  belongs_to :territory_user

  validates :diagnosed_need, presence: true
  validates_with SelectedAssistanceExpertValidator

  scope :not_viewed, (-> { where(expert_viewed_page_at: nil) })
  scope :of_expert, (->(expert) { joins(:assistance_expert).where(assistances_experts: { expert: expert }) })
  scope :of_diagnoses, (lambda do |diagnoses|
    joins(diagnosed_need: :diagnosis).where(diagnosed_needs: { diagnosis: diagnoses })
  end)
  scope :with_status, (->(status) { where(status: status) })
  scope :updated_more_than_five_days_ago, (-> { where('updated_at < ?', 5.days.ago) })
  scope :needing_taking_care_update, (-> { with_status(:taking_care).updated_more_than_five_days_ago })
  scope :with_no_one_in_charge, (lambda do
    ids = SelectedAssistanceExpert.select(:diagnosed_need_id).group(:diagnosed_need_id).having('SUM(status) = 0')
    where(diagnosed_need_id: ids).updated_more_than_five_days_ago
  end)
end
