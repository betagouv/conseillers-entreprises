# frozen_string_literal: true

# TODO: Rename for ContactedExpert
class SelectedAssistanceExpert < ApplicationRecord
  audited only: :status

  enum status: { quo: 0, taking_care: 1, done: 2, not_for_me: 3 }, _prefix: true

  belongs_to :diagnosed_need
  belongs_to :assistance_expert, foreign_key: :assistances_experts_id
  belongs_to :relay
  has_one :expert, through: :assistance_expert
  has_many :territories, through: :expert

  validates :diagnosed_need, presence: true
  validates_with SelectedAssistanceExpertValidator

  after_update :update_taken_care_of_at
  after_update :update_closed_at

  scope :not_viewed, (-> { where(expert_viewed_page_at: nil) })
  scope :of_expert, (->(expert) { joins(:assistance_expert).where(assistances_experts: { expert: expert }) })
  scope :of_relay, (->(relay) { where(relay: relay) })
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

  def status_closed?
    status_done? || status_not_for_me?
  end

  private

  def update_taken_care_of_at
    if (status_taking_care? || status_closed?) && !taken_care_of_at
      update_columns taken_care_of_at: Time.now
    end

    if status_quo? && taken_care_of_at
      update_columns taken_care_of_at: nil
    end
  end

  def update_closed_at
    if status_closed? && !closed_at
      update_columns closed_at: Time.now
    end

    if (status_quo? || status_taking_care?) && closed_at
      update_columns closed_at: nil
    end
  end
end
