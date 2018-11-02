# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  LAST_STEP = 5
  AUTHORIZED_STEPS = (1..LAST_STEP).to_a.freeze

  belongs_to :visit, validate: true, dependent: :destroy

  has_many :diagnosed_needs, dependent: :destroy
  accepts_nested_attributes_for :diagnosed_needs, allow_destroy: true
  has_many :questions, through: :diagnosed_needs
  has_many :matches, -> { ordered_by_status }, through: :diagnosed_needs
  has_many :experts, through: :matches
  has_many :relays, through: :matches

  validates :visit, presence: true
  accepts_nested_attributes_for :visit
  validates :step, inclusion: { in: AUTHORIZED_STEPS }

  scope :of_siret, (-> (siret) { joins(:visit).merge(Visit.of_siret(siret)) })
  scope :of_user, (-> (user) { joins(:visit).where(visits: { advisor: user }) })
  scope :reverse_chronological, (-> { order(created_at: :desc) })
  scope :in_progress, (-> { where(step: [1..LAST_STEP - 1]) })
  scope :completed, (-> { where(step: LAST_STEP) })
  scope :in_territory, (-> (territory) { of_facilities(Facility.in_territory(territory)) })
  scope :of_facilities, (-> (facilities) { joins(:visit).merge(Visit.where(facility: facilities)) })
  scope :available_for_expert, (lambda do |expert|
    joins(diagnosed_needs: [matches: [assistance_expert: :expert]])
      .where(diagnosed_needs: { matches: { assistance_expert: { experts: { id: expert.id } } } })
  end)

  scope :of_relay_or_expert, (lambda do |relay_or_expert|
    only_active
      .includes(visit: [facility: :company])
      .joins(:diagnosed_needs)
      .merge(DiagnosedNeed.of_relay_or_expert(relay_or_expert))
      .order('visits.happened_on desc', 'visits.created_at desc')
      .distinct
  end)

  scope :after_step, (-> (minimum_step) { where('step >= ?', minimum_step) })

  scope :only_active, (-> { where(archived_at: nil) })

  def archive!
    self.archived_at = Time.now
    self.save!
  end

  def unarchive!
    self.archived_at = nil
    self.save!
  end

  def can_be_viewed_by?(role)
    visit.can_be_viewed_by?(role) || diagnosed_needs.any?{ |need| need.can_be_viewed_by?(role) }
  end

  def contacted_persons
    (relays.map(&:user) + experts).uniq
  end
end
