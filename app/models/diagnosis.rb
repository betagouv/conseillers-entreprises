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
#  advisor_id  :bigint(8)        not null
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

  ## Validations and Callbacks
  #
  validates :advisor, :facility, presence: true
  validates :step, inclusion: { in: AUTHORIZED_STEPS }
  validate :step_4_has_visit_attributes
  validate :last_step_has_matches
  after_update :last_step_notify, if: :saved_change_to_step?

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
  has_one :advisor_institution, through: :advisor, source: :institution, inverse_of: :sent_diagnoses

  # :expert
  has_many :expert_antennes, through: :experts, source: :antenne, inverse_of: :received_diagnoses
  has_many :expert_institutions, through: :experts, source: :institution, inverse_of: :received_diagnoses
  has_many :contacted_users, through: :experts, source: :users, inverse_of: :received_diagnoses

  ## Scopes
  #
  scope :in_progress, -> { where(step: [1..LAST_STEP - 1]) }
  scope :completed, -> { where(step: LAST_STEP) }
  scope :available_for_expert, -> (expert) do
    joins(needs: [matches: [:expert]])
      .where(needs: { matches: { experts: { id: expert.id } } })
  end

  scope :after_step, -> (minimum_step) { where('step >= ?', minimum_step) }

  def match_and_notify!(experts_skills_for_needs)
    self.transaction do
      experts_skills_for_needs.each do |need_id, experts_skills_ids|
        need = self.needs.find(need_id)
        need.create_matches!(experts_skills_ids)
      end
      self.update!(step: Diagnosis::LAST_STEP)
    end
  end

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

  def completed_at
    # This is debatable:
    # last_step_has_matches guarantees that completed diagnoses have matches
    # and we know matches are created when the diagnosis is completed.
    # We could also add a diagnoses.completed_at column;
    # if we ever want to use completed_at for queries, that’ll be necessary.
    matches&.first&.created_at
  end

  ##
  #
  def can_be_viewed_by?(role)
    # diagnosis advisor
    if role.present? && advisor == role
      return true
    end

    # support team
    if role.is_a?(Expert) && role.experts_skills.support_for(self).present?
      return true
    end

    # contacted experts
    needs.any? { |need| need.experts.include?(role) }
  end

  def can_be_modified_by?(role)
    # diagnosis advisor
    if role.present? && advisor == role
      return true
    end

    # support team
    if role.is_a?(Expert) && role.experts_skills.support_for(self).present?
      return true
    end

    false
  end

  private

  def step_4_has_visit_attributes
    if step == 4
      if visitee.nil?
        errors.add(:visitee, :blank)
      end
      if happened_on.nil?
        errors.add(:happened_on, :blank)
      end
    end
  end

  def last_step_has_matches
    if step == LAST_STEP && needs&.flat_map(&:matches)&.empty? # Note: we can’t rely on `self.matches` (a :through association) before the objects are actually saved
      errors.add(:step, 'can’t be step 5 with no matches')
    end
  end

  def last_step_notify
    if step == LAST_STEP
      notify_experts!
    end
  end

  def notify_experts!
    experts.each do |expert|
      ExpertMailer.delay.notify_company_needs(expert, self)
    end
  end
end
