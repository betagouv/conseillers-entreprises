# == Schema Information
#
# Table name: diagnoses
#
#  id          :bigint(8)        not null, primary key
#  archived_at :datetime
#  content     :text
#  happened_on :date
#  step        :integer          default(1)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  advisor_id  :bigint(8)
#  facility_id :bigint(8)
#  visitee_id  :bigint(8)
#
# Indexes
#
#  index_diagnoses_on_advisor_id   (advisor_id)
#  index_diagnoses_on_archived_at  (archived_at)
#  index_diagnoses_on_facility_id  (facility_id)
#  index_diagnoses_on_visitee_id   (visitee_id)
#
# Foreign Keys
#
#  fk_rails_...  (advisor_id => users.id)
#  fk_rails_...  (facility_id => facilities.id)
#  fk_rails_...  (visitee_id => contacts.id)
#

class Diagnosis < ApplicationRecord
  ##
  #
  include Archivable

  ## Constants
  #
  LAST_STEP = 5
  AUTHORIZED_STEPS = (1..LAST_STEP).to_a.freeze

  ## Associations
  #
  belongs_to :facility, inverse_of: :diagnoses
  belongs_to :advisor, class_name: 'User', inverse_of: :sent_diagnoses
  belongs_to :visitee, class_name: 'Contact', inverse_of: :diagnoses, optional: true

  has_many :needs, dependent: :destroy, inverse_of: :diagnosis

  ## Validations
  #
  validates :advisor, :facility, presence: true
  validates :step, inclusion: { in: AUTHORIZED_STEPS }

  accepts_nested_attributes_for :needs, allow_destroy: true
  accepts_nested_attributes_for :visitee

  ## Through Associations
  #
  # :facility
  has_one :company, through: :facility, inverse_of: :diagnoses
  has_many :facility_territories, through: :facility, source: :territories, inverse_of: :diagnoses

  # :needs
  has_many :subjects, through: :needs, inverse_of: :diagnoses
  has_many :matches, through: :needs, inverse_of: :diagnosis

  # :matches
  has_many :experts, through: :matches, inverse_of: :received_diagnoses

  # :advisor
  has_one :advisor_antenne, through: :advisor, source: :antenne, inverse_of: :sent_diagnoses
  has_one :advisor_institution, through: :advisor, source: :antenne_institution, inverse_of: :sent_diagnoses

  # :expert
  has_many :expert_antennes, through: :experts, source: :antenne, inverse_of: :received_diagnoses
  has_many :expert_institutions, through: :experts, source: :antenne_institution, inverse_of: :received_diagnoses

  ## Scopes
  #
  scope :in_progress, -> { where(step: [1..LAST_STEP - 1]) }
  scope :completed, -> { where(step: LAST_STEP) }
  scope :available_for_expert, -> (expert) do
    joins(needs: [matches: [expert_skill: :expert]])
      .where(needs: { matches: { expert_skill: { experts: { id: expert.id } } } })
  end

  scope :of_expert, -> (expert) do
    archived(false)
      .includes(facility: :company)
      .joins(:needs)
      .merge(Need.of_expert(expert))
      .order(happened_on: :desc, created_at: :desc)
      .distinct
  end

  scope :after_step, -> (minimum_step) { where('step >= ?', minimum_step) }

  ##
  #
  def to_s
    "#{company.name} (#{I18n.l display_date})"
  end

  def display_date
    happened_on || created_at.to_date
  end

  def completed?
    step == LAST_STEP
  end

  def in_progress?
    step < LAST_STEP
  end

  ##
  #
  def can_be_viewed_by?(role)
    if role.present? && advisor == role
      true
    else
      needs.any?{ |need| need.can_be_viewed_by?(role) }
    end
  end

  ##
  #
  def contacted_persons
    experts.uniq
  end
end
