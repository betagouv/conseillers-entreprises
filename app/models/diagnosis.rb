# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  LAST_STEP = 5
  AUTHORIZED_STEPS = (1..LAST_STEP).to_a.freeze
  acts_as_paranoid

  attr_accessor :diagnosed_needs_count, :selected_assistances_experts_count, :solved_needs_count

  belongs_to :visit

  has_many :diagnosed_needs
  accepts_nested_attributes_for :diagnosed_needs

  validates :visit, presence: true
  validates :step, inclusion: { in: AUTHORIZED_STEPS }

  scope :of_siret, (->(siret) { joins(:visit).merge(Visit.of_siret(siret)) })
  scope :of_user, (->(user) { joins(:visit).where(visits: { advisor: user }) })
  scope :reverse_chronological, (-> { order(created_at: :desc) })
  scope :in_progress, (-> { where(step: [1..LAST_STEP - 1]) })
  scope :completed, (-> { where(step: LAST_STEP) })
  scope :available_for_expert, (lambda do |expert|
    joins(diagnosed_needs: [selected_assistance_experts: [assistance_expert: :expert]])
      .where(diagnosed_needs: { selected_assistance_experts: { assistance_expert: { experts: { id: expert.id } } } })
  end)

  def creation_date_localized
    I18n.l(created_at.to_date)
  end

  def can_be_viewed_by?(user)
    visit.can_be_viewed_by?(user)
  end
end
