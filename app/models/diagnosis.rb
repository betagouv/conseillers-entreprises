# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  LAST_STEP = 5
  AUTHORIZED_STEPS = (1..LAST_STEP).to_a.freeze

  attr_accessor :diagnosed_needs_count, :matches_count, :solved_needs_count

  belongs_to :visit, validate: true

  has_many :diagnosed_needs
  accepts_nested_attributes_for :diagnosed_needs

  validates :visit, presence: true
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

  def creation_date_localized
    I18n.l created_at.to_date
  end

  def can_be_viewed_by?(user)
    visit.can_be_viewed_by?(user)
  end

  def needs_for(relay_or_expert)
    needs = diagnosed_needs.includes(:matches)
    if relay_or_expert.is_a?(Expert)
      needs.of_expert(relay_or_expert)
    elsif relay_or_expert.is_a?(Relay)
      needs.of_relay(relay_or_expert)
    end
  end
end
