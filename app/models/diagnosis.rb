# == Schema Information
#
# Table name: diagnoses
#
#  id                   :bigint(8)        not null, primary key
#  archived_at          :datetime
#  completed_at         :datetime
#  content              :text
#  happened_on          :date
#  retention_email_sent :boolean          default(FALSE)
#  step                 :integer          default("not_started")
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  advisor_id           :bigint(8)
#  facility_id          :bigint(8)        not null
#  solicitation_id      :bigint(8)
#  visitee_id           :bigint(8)
#
# Indexes
#
#  index_diagnoses_on_advisor_id       (advisor_id)
#  index_diagnoses_on_archived_at      (archived_at)
#  index_diagnoses_on_facility_id      (facility_id)
#  index_diagnoses_on_solicitation_id  (solicitation_id)
#  index_diagnoses_on_visitee_id       (visitee_id)
#
# Foreign Keys
#
#  fk_rails_...  (advisor_id => users.id)
#  fk_rails_...  (facility_id => facilities.id)
#  fk_rails_...  (solicitation_id => solicitations.id)
#  fk_rails_...  (visitee_id => contacts.id)
#

class Diagnosis < ApplicationRecord
  ##
  #
  include Archivable
  include DiagnosisCreation::DiagnosisMethods

  ## Constants
  #
  enum step: { not_started: 1, needs: 2, visit: 3, matches: 4, completed: 5 }, _prefix: true

  ## Associations
  #
  belongs_to :facility, inverse_of: :diagnoses
  belongs_to :advisor, class_name: 'User', inverse_of: :sent_diagnoses, optional: true
  belongs_to :visitee, class_name: 'Contact', inverse_of: :diagnoses, optional: true
  belongs_to :solicitation, optional: true, inverse_of: :diagnosis, touch: true
  has_many :needs, dependent: :destroy, inverse_of: :diagnosis

  has_many :themes, through: :needs, inverse_of: :diagnoses

  ## Validations and Callbacks
  #
  validate :step_visit_has_needs
  validate :step_matches_has_visit_attributes
  validate :step_completed_has_matches
  validate :step_completed_has_advisor
  validate :without_solicitation_has_advisor

  accepts_nested_attributes_for :facility
  accepts_nested_attributes_for :needs, allow_destroy: true
  accepts_nested_attributes_for :visitee

  ## Through Associations
  #
  # :facility
  has_one :company, through: :facility, inverse_of: :diagnoses
  has_many :facility_territories, through: :facility, source: :territories, inverse_of: :diagnoses

  # :needs
  has_many :subjects, through: :needs, inverse_of: :diagnoses
  has_many :themes, through: :subjects, inverse_of: :diagnoses
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

  ## Callbacks
  #
  after_update :update_needs, if: :step_completed?

  ## Scopes
  #
  scope :from_solicitation, -> { where.not(solicitation: nil) }
  scope :from_visit, -> { where(solicitation: nil) }
  scope :in_progress, -> { where.not(step: :completed) }
  scope :completed, -> { where(step: :completed) }
  scope :available_for_expert, -> (expert) do
    joins(needs: [matches: [:expert]])
      .where(needs: { matches: { experts: { id: expert.id } } })
  end

  scope :after_step, -> (minimum_step) { where('step >= ?', minimum_step) }

  scope :min_closed_at, -> (range) do
    joins(:matches)
      .merge(Match.status_done)
      .group(:id)
      .having("MIN(matches.closed_at) BETWEEN ? AND ?", range.begin, range.end)
  end

  scope :out_of_deployed_territories, -> {
    left_outer_joins(:facility_territories)
      .where(territories: { id: nil })
  }

  ## Scopes for flags
  #
  FLAGS = %i[retention_email_sent satisfaction_email_sent]
  FLAGS.each do |flag|
    scope flag, -> { where(flag => true) }
    scope "not_#{flag}", -> { where(flag => false) }
  end

  ##
  #
  def to_s
    "#{company.name} (#{I18n.l display_date})"
  end

  def display_date
    happened_on || created_at.to_date
  end

  def from_solicitation?
    solicitation_id.present?
  end

  def from_visit?
    solicitation_id.nil?
  end

  ## Matching
  #
  def notify_matches_made!
    # Notify experts
    experts.each do |expert|
      self.needs.each do |need|
        ExpertMailer.notify_company_needs(expert, need).deliver_later
      end
      expert.first_notification_help_email
    end
  end

  private

  def update_needs
    needs.each{ |n| n.update_status }
  end

  def step_visit_has_needs
    if step_visit?
      if needs.blank?
        errors.add(:needs, :blank)
      end
    end
  end

  def step_matches_has_visit_attributes
    if step_matches?
      if visitee.nil?
        errors.add(:visitee, :blank)
      end
      if happened_on.nil?
        errors.add(:happened_on, :blank)
      end
    end
  end

  def step_completed_has_matches
    if step_completed?
      # On regarde qu'il n'y ait aucun besoin sans match
      if needs.empty? || needs&.map(&:matches)&.any?{ |m| m.empty? } # Note: we can’t rely on `self.matches` (a :through association) before the objects are actually saved
        errors.add(:base, :cant_send_need_without_matches)
      end
    end
  end

  def step_completed_has_advisor
    if step_completed?
      if advisor.nil?
        errors.add(:advisor, :blank)
      end
    end
  end

  def without_solicitation_has_advisor
    if solicitation.nil?
      if advisor.nil?
        errors.add(:advisor, :blank)
      end
    end
  end
end
