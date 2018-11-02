# frozen_string_literal: true

class Match < ApplicationRecord
  audited only: :status

  enum status: { quo: 0, taking_care: 1, done: 2, not_for_me: 3 }, _prefix: true

  belongs_to :diagnosed_need, counter_cache: true
  has_one :diagnosis, through: :diagnosed_need
  belongs_to :assistance_expert, foreign_key: :assistances_experts_id
  belongs_to :relay
  has_one :expert, through: :assistance_expert
  has_many :territories, through: :expert
  has_many :feedbacks, dependent: :destroy

  validates :diagnosed_need, presence: true
  validates_with MatchValidator

  after_update :update_taken_care_of_at
  after_update :update_closed_at

  scope :ordered_by_status, -> { order(status: :desc, id: :asc) }

  scope :not_viewed, (-> { where(expert_viewed_page_at: nil) })

  scope :of_diagnoses, (lambda do |diagnoses|
    joins(diagnosed_need: :diagnosis).where(diagnosed_needs: { diagnosis: diagnoses })
  end)
  scope :with_status, (-> (status) { where(status: status) })
  scope :updated_more_than_five_days_ago, (-> { where('updated_at < ?', 5.days.ago) })
  scope :needing_taking_care_update, (-> { with_status(:taking_care).updated_more_than_five_days_ago })

  scope :in_territory, (-> (territory) { of_diagnoses(Diagnosis.in_territory(territory)) })
  scope :of_facilities, (-> (facilities) { of_diagnoses(Diagnosis.of_facilities(facilities)) })

  scope :of_relay_or_expert, (lambda do |relay_or_expert|
    if relay_or_expert.is_a?(Enumerable)
      relations = relay_or_expert.map{ |item| of_relay_or_expert(item) }.compact
      relations.reduce(&:or)
    elsif relay_or_expert.is_a?(Expert)
      left_outer_joins(:assistance_expert).where(assistances_experts: { expert: relay_or_expert })
    elsif relay_or_expert.is_a?(Relay)
      left_outer_joins(:assistance_expert).where(relay: relay_or_expert)
    else
      left_outer_joins(:assistance_expert).where(id: -1)
    end
  end)

  scope :sent_by, -> (users) {
    joins(diagnosis: [visit: :advisor])
      .where(diagnoses: { visits: { advisor: users } })
  }

  def status_closed?
    status_done? || status_not_for_me?
  end

  def expert_description
    "#{expert_full_name} (#{expert_institution_name})"
  end

  def person
    expert || relay&.user
  end

  def person_full_name
    person&.full_name || expert_full_name
  end

  def belongs_to_relay_or_expert?(role)
    role.present? && (expert == role || relay == role)
  end

  def can_be_viewed_by?(role)
    belongs_to_relay_or_expert?(role)
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
