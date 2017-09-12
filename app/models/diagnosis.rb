# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  AUTHORIZED_STEPS = [1, 2, 3, 4, 5].freeze
  acts_as_paranoid

  belongs_to :visit

  has_many :diagnosed_needs
  accepts_nested_attributes_for :diagnosed_needs

  validates :visit, presence: true
  validates :step, inclusion: { in: AUTHORIZED_STEPS }

  scope :of_visit, (->(visit) { where(visit: visit) })
  scope :of_user, (->(user) { joins(:visit).where(visits: { advisor: user }) })
  scope :reverse_chronological, (-> { order(created_at: :desc) })
  scope :limited, (-> { limit(15) })
  scope :in_progress, (-> { where(step: [1..4]) })
  scope :completed, (-> { where(step: 5) })

  def creation_date_localized
    I18n.l(created_at.to_date)
  end

  def selected_assistance_experts_count
    diagnosed_needs.reduce(0) { |sum, diagnosed_need| sum + diagnosed_need.selected_assistance_experts.count }
  end

  def can_be_viewed_by?(user)
    visit.advisor == user
  end
end
