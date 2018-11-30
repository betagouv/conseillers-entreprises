# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  ## Constants
  #
  LAST_STEP = 5
  AUTHORIZED_STEPS = (1..LAST_STEP).to_a.freeze

  ## Associations
  #
  belongs_to :visit, validate: true, dependent: :destroy
  has_one :facility, through: :visit, inverse_of: :diagnoses # TODO: should be direct once we merge the Visit and Diagnosis models
  has_one :advisor, through: :visit, inverse_of: :sent_diagnoses # TODO: should be direct once we merge the Visit and Diagnosis models

  has_many :diagnosed_needs, dependent: :destroy, inverse_of: :diagnosis

  ## Validations
  #
  validates :visit, presence: true
  validates :step, inclusion: { in: AUTHORIZED_STEPS }

  accepts_nested_attributes_for :diagnosed_needs, allow_destroy: true
  accepts_nested_attributes_for :visit

  ## Through Associations
  #
  # :facility
  has_one :company, through: :facility, inverse_of: :diagnoses
  has_one :facility_territories, through: :facility, source: :territories, inverse_of: :diagnoses

  # :diagnosed_needs
  has_many :questions, through: :diagnosed_needs, inverse_of: :diagnoses
  has_many :matches, through: :diagnosed_needs, inverse_of: :diagnosis

  # :matches
  has_many :experts, through: :matches, inverse_of: :received_diagnoses
  has_many :relays, through: :matches

  # :advisor
  has_one :advisor_antenne, through: :advisor, source: :antenne, inverse_of: :sent_diagnoses
  has_one :advisor_institution, through: :advisor, source: :antenne_institution, inverse_of: :sent_diagnoses

  ## Scopes
  #
  scope :of_user, (-> (user) { joins(:visit).where(visits: { advisor: user }) })
  scope :reverse_chronological, (-> { order(created_at: :desc) })
  scope :in_progress, (-> { where(step: [1..LAST_STEP - 1]) })
  scope :completed, (-> { where(step: LAST_STEP) })
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

  ##
  #
  def to_s
    "#{facility} #{visit.display_date}"
  end

  ##
  #
  def archive!
    self.archived_at = Time.now
    self.save!
  end

  def unarchive!
    self.archived_at = nil
    self.save!
  end

  def archived?
    archived_at.present?
  end

  ##
  #
  def can_be_viewed_by?(role)
    visit.can_be_viewed_by?(role) || diagnosed_needs.any?{ |need| need.can_be_viewed_by?(role) }
  end

  ##
  #
  def contacted_persons
    (relays.map(&:user) + experts).uniq
  end
end
