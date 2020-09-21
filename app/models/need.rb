# == Schema Information
#
# Table name: needs
#
#  id                      :bigint(8)        not null, primary key
#  archived_at             :datetime
#  content                 :text
#  last_activity_at        :datetime         not null
#  matches_count           :integer
#  satisfaction_email_sent :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  diagnosis_id            :bigint(8)        not null
#  subject_id              :bigint(8)        not null
#
# Indexes
#
#  index_needs_on_archived_at                  (archived_at)
#  index_needs_on_diagnosis_id                 (diagnosis_id)
#  index_needs_on_subject_id                   (subject_id)
#  index_needs_on_subject_id_and_diagnosis_id  (subject_id,diagnosis_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (diagnosis_id => diagnoses.id)
#  fk_rails_...  (subject_id => subjects.id)
#

class Need < ApplicationRecord
  ##
  #
  include Archivable

  ## Associations
  #
  belongs_to :diagnosis, inverse_of: :needs, touch: true
  belongs_to :subject, inverse_of: :needs
  has_many :matches, dependent: :destroy, inverse_of: :need
  has_many :feedbacks, dependent: :destroy, as: :feedbackable
  has_one :company_satisfaction, dependent: :destroy, inverse_of: :need

  ## Validations
  #
  validates :diagnosis, presence: true
  validates :subject, uniqueness: { scope: :diagnosis_id }

  accepts_nested_attributes_for :matches, allow_destroy: true

  ## Callbacks
  #
  after_touch :update_last_activity_at

  ## Through Associations
  #
  # :diagnosis
  has_one :facility, through: :diagnosis, inverse_of: :needs
  has_one :company, through: :diagnosis, inverse_of: :needs
  has_one :advisor, through: :diagnosis, inverse_of: :sent_needs

  # :matches
  has_many :experts, -> { distinct }, through: :matches, inverse_of: :received_needs

  # :facility
  has_many :facility_territories, through: :facility, source: :territories, inverse_of: :needs

  # :advisor
  has_one :advisor_antenne, through: :advisor, source: :antenne, inverse_of: :sent_needs
  has_one :advisor_institution, through: :advisor, source: :institution, inverse_of: :sent_needs

  # :experts
  has_many :expert_antennes, through: :experts, source: :antenne, inverse_of: :received_needs
  has_many :expert_institutions, through: :experts, source: :institution, inverse_of: :received_needs
  has_many :contacted_users, through: :experts, source: :users, inverse_of: :received_needs

  # :subject
  has_one :theme, through: :subject, inverse_of: :needs

  ## Scopes
  #
  ABANDONED_DELAY = 2.weeks
  REMINDER_DELAY = 10.days
  REMINDER_ABANDONED_DELAY = 30.days

  scope :made_in, -> (date_range) do
    joins(:diagnosis)
      .where(diagnoses: { happened_on: date_range })
      .distinct
  end
  scope :ordered_for_interview, -> do
    left_outer_joins(:subject)
      .merge(Subject.ordered_for_interview)
  end

  scope :diagnosis_completed, -> do
    joins(:diagnosis)
      .merge(Diagnosis.completed)
  end

  scope :abandoned_quo_not_taken, -> do
    by_status(:quo)
      .archived(false)
      .abandoned
  end

  scope :reminder_quo_not_taken, -> do
    by_status(:quo)
      .archived(false)
      .reminder
      .left_outer_joins(:feedbacks)
      .group('needs.id')
      .having('feedbacks.count < ?', 1)
  end

  scope :reminder_in_progress, -> do
    by_status(:quo)
      .archived(false)
      .joins(:feedbacks)
  end

  scope :abandoned_without_taking_care, -> do
    with_matches_only_in_status([:quo, :done_no_help, :done_not_reachable, :not_for_me])
      .archived(false)
      .reminder_abandoned
  end

  scope :abandoned_taken_not_done, -> do
    by_status(:taking_care)
      .archived(false)
      .abandoned
  end
  scope :rejected, -> do
    by_status(:not_for_me)
      .archived(false)
  end

  scope :min_closed_at, -> (range) do
    joins(:matches)
      .merge(Match.status_done)
      .group(:id)
      .having("MIN(matches.closed_at) BETWEEN ? AND ?", range.begin, range.end)
  end

  scope :reminder, -> { left_outer_joins(:matches).where('matches.created_at < ?', REMINDER_DELAY.ago) }

  scope :reminder_abandoned, -> { left_outer_joins(:matches).where('matches.created_at < ?', REMINDER_ABANDONED_DELAY.ago) }

  scope :abandoned, -> { where("needs.last_activity_at < ?", ABANDONED_DELAY.ago) }

  scope :with_some_matches_in_status, -> (status) do # can be an array
    joins(:matches).where(matches: Match.unscoped.where(status: status)).distinct
  end
  scope :with_matches_only_in_status, -> (status) do # can be an array
    left_outer_joins(:matches).where.not(matches: Match.unscoped.where.not(status: status)).distinct
  end

  scope :by_status, -> (status) do
    case status.to_sym
    when :diagnosis_not_complete
      where.not(id: diagnosis_completed)
    when :sent_to_no_one
      diagnosis_completed
        .left_outer_joins(:matches).where('matches.id IS NULL').distinct
    when :quo
      with_matches_only_in_status([:quo, :not_for_me])
        .with_some_matches_in_status(:quo)
    when :taking_care
      with_some_matches_in_status(:taking_care)
        .with_matches_only_in_status([:quo, :taking_care, :not_for_me])
    when :done
      with_some_matches_in_status(:done)
    when :not_for_me
      with_some_matches_in_status(:not_for_me)
        .with_matches_only_in_status(:not_for_me)
    end
  end

  scope :active, -> do
    archived(false)
      .with_matches_only_in_status([:quo, :taking_care, :not_for_me])
      .with_some_matches_in_status([:quo, :taking_care])
  end

  ## ActiveAdmin/Ransacker helpers
  #
  ransacker(:by_status, formatter: -> (value) {
    by_status(value).ids.presence
  }) { |parent| parent.table[:id] }

  ##
  #
  def to_s
    "#{company} : #{subject}"
  end

  def initial_matches_at
    matches.pluck(:created_at).min
  end

  def abandoned?
    updated_at < ABANDONED_DELAY.ago
  end

  def quo_experts
    Expert.joins(:received_matches).merge(matches.status_quo)
  end

  ## Status
  #
  # Need.status isn't an enum, but we want human_attribute_values and friends to work the same.
  def self.statuses
    { "diagnosis_not_complete" => -2, "sent_to_no_one" => -1, "quo" => 0, "taking_care" => 1, "done" => 2, "not_for_me" => 3, }
  end

  def status
    return :diagnosis_not_complete unless diagnosis.step_completed?

    matches_status = matches.pluck(:status).map(&:to_sym)

    if matches_status.empty?
      :sent_to_no_one
    elsif matches_status.include?(:done)
      :done
    elsif matches_status.include?(:taking_care)
      :taking_care
    elsif matches_status.include?(:quo)
      :quo
    else # matches_status.all?{ |o| o == :not_for_me }
      :not_for_me
    end
  end

  private

  def update_last_activity_at
    last_activity = matches.pluck(:updated_at).compact.max || updated_at
    update_columns last_activity_at: last_activity
  end
end
