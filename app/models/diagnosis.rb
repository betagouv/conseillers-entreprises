# == Schema Information
#
# Table name: diagnoses
#
#  id          :bigint(8)        not null, primary key
#  archived_at :datetime
#  content     :text
#  happened_on :date
#  step        :integer          default("not_started")
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
  include DiagnosisCreation

  ## Constants
  #
  enum step: { not_started: 1, besoins: 2, visite: 3, selection: 4, completed: 5 }, _prefix: true

  ## Associations
  #
  belongs_to :facility, inverse_of: :diagnoses
  belongs_to :advisor, class_name: 'User', inverse_of: :sent_diagnoses
  belongs_to :visitee, class_name: 'Contact', inverse_of: :diagnoses, optional: true

  has_many :needs, dependent: :destroy, inverse_of: :diagnosis

  ## Validations and Callbacks
  #
  validates :advisor, :facility, presence: true
  validate :step_4_has_visit_attributes
  validate :last_step_has_matches

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
  scope :in_progress, -> { where.not(step: :completed) }
  scope :completed, -> { where(step: :completed) }
  scope :available_for_expert, -> (expert) do
    joins(needs: [matches: [:expert]])
      .where(needs: { matches: { experts: { id: expert.id } } })
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

  def completed_at
    # This is debatable:
    # last_step_has_matches guarantees that completed diagnoses have matches
    # and we know matches are created when the diagnosis is completed.
    # We could also add a diagnoses.completed_at column;
    # if we ever want to use completed_at for queries, that’ll be necessary.
    matches&.first&.created_at
  end

  ## Matching
  #
  def match_and_notify!(experts_and_subjects_for_needs)
    update_result = self.transaction do
      experts_and_subjects_for_needs.each do |need_id, experts_and_subjects_ids|
        need = self.needs.find(need_id)
        need.create_matches!(experts_and_subjects_ids)
      end
      self.update!(step: Diagnosis.steps[:completed])
    end
    notify_experts!
    update_result
  end

  def notify_experts!
    experts.each do |expert|
      ExpertMailer.notify_company_needs(expert, self).deliver_later
    end
    unless advisor.disable_email_confirm_notifications_sent.to_bool
      UserMailer.confirm_notifications_sent(self).deliver_later
    end
  end

  private

  def step_4_has_visit_attributes
    if Diagnosis.steps[step] == 4
      if visitee.nil?
        errors.add(:visitee, :blank)
      end
      if happened_on.nil?
        errors.add(:happened_on, :blank)
      end
    end
  end

  def last_step_has_matches
    if step_completed? && needs&.flat_map(&:matches)&.empty? # Note: we can’t rely on `self.matches` (a :through association) before the objects are actually saved
      errors.add(:step, 'can’t be step 5 with no matches')
    end
  end
end
