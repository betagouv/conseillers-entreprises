# == Schema Information
#
# Table name: needs
#
#  id            :bigint(8)        not null, primary key
#  archived_at   :datetime
#  content       :text
#  matches_count :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  diagnosis_id  :bigint(8)        not null
#  subject_id    :bigint(8)        not null
#
# Indexes
#
#  index_needs_on_archived_at   (archived_at)
#  index_needs_on_diagnosis_id  (diagnosis_id)
#  index_needs_on_subject_id    (subject_id)
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
  belongs_to :diagnosis, inverse_of: :needs
  belongs_to :subject, inverse_of: :needs
  has_many :matches, dependent: :destroy, inverse_of: :need

  ## Validations
  #
  validates :diagnosis, presence: true
  validates :subject, uniqueness: { scope: :diagnosis_id, allow_nil: true }

  ## Through Associations
  #
  # :diagnosis
  has_one :facility, through: :diagnosis, inverse_of: :needs
  has_one :company, through: :diagnosis, inverse_of: :needs
  has_one :advisor, through: :diagnosis, inverse_of: :sent_needs

  # :matches
  has_many :experts, -> { distinct }, through: :matches, inverse_of: :received_needs
  has_many :feedbacks, through: :matches, inverse_of: :need

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
  scope :abandoned_taken_not_done, -> do
    by_status(:taking_care)
      .archived(false)
      .abandoned
  end
  scope :rejected, -> do
    by_status(:not_for_me)
      .archived(false)
  end

  scope :no_activity_after, -> (date) do
    where.not("needs.updated_at > ?", date)
      .left_outer_joins(:matches)
      .where.not(matches: Match.where('updated_at > ?', date))
      .left_outer_joins(:feedbacks)
      .where.not(feedbacks: Feedback.where('updated_at > ?', date))
      .distinct
  end

  scope :abandoned, -> { no_activity_after(3.weeks.ago) }

  scope :with_some_matches_in_status, -> (status) do # can be an array
    joins(:matches).where(matches: Match.where(status: status)).distinct
  end
  scope :with_matches_only_in_status, -> (status) do # can be an array
    left_outer_joins(:matches).where.not(matches: Match.where.not(status: status)).distinct
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
    by_status(value).pluck(:id)
      .presence
  }) { |parent| parent.table[:id] }

  ##
  #
  def to_s
    "#{company} : #{subject}"
  end

  def last_activity_at
    dates = [updated_at, matches.pluck(:updated_at), feedbacks.pluck(:updated_at)].flatten
    dates.max
  end

  def abandoned?
    last_activity_at < 3.weeks.ago
  end

  ## Status
  #
  STATUSES = %i[
    diagnosis_not_complete
    sent_to_no_one
    quo
    taking_care
    done
    not_for_me
  ]

  def status
    return :diagnosis_not_complete if !diagnosis.completed?

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

  include StatusHelper::StatusDescription

  ##
  #
  def create_matches!(expert_skill_ids)
    expert_skills = ExpertSkill.where(id: expert_skill_ids)
    self.matches.create(expert_skills.map{ |es| es.slice(:expert, :skill) })
  end
end
