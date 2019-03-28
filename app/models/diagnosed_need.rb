# == Schema Information
#
# Table name: diagnosed_needs
#
#  id            :bigint(8)        not null, primary key
#  archived_at   :datetime
#  content       :text
#  matches_count :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  diagnosis_id  :bigint(8)
#  question_id   :bigint(8)        not null
#
# Indexes
#
#  index_diagnosed_needs_on_archived_at   (archived_at)
#  index_diagnosed_needs_on_diagnosis_id  (diagnosis_id)
#  index_diagnosed_needs_on_question_id   (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (diagnosis_id => diagnoses.id)
#  fk_rails_...  (question_id => questions.id)
#

class DiagnosedNeed < ApplicationRecord
  ##
  #
  include Archivable

  ## Associations
  #
  belongs_to :diagnosis, inverse_of: :diagnosed_needs
  belongs_to :question, inverse_of: :diagnosed_needs
  has_many :matches, dependent: :destroy, inverse_of: :diagnosed_need

  ## Validations
  #
  validates :diagnosis, presence: true
  validates :question, uniqueness: { scope: :diagnosis_id, allow_nil: true }

  ## Through Associations
  #
  # :diagnosis
  has_one :facility, through: :diagnosis, inverse_of: :diagnosed_needs
  has_one :company, through: :diagnosis, inverse_of: :diagnosed_needs
  has_one :advisor, through: :diagnosis, inverse_of: :sent_diagnosed_needs

  # :matches
  has_many :experts, through: :matches, inverse_of: :received_diagnosed_needs
  has_many :relays, through: :matches
  has_many :feedbacks, through: :matches, inverse_of: :diagnosed_need

  # :facility
  has_many :facility_territories, through: :facility, source: :territories, inverse_of: :diagnosed_needs

  # :advisor
  has_one :advisor_antenne, through: :advisor, source: :antenne, inverse_of: :sent_diagnosed_needs
  has_one :advisor_institution, through: :advisor, source: :antenne_institution, inverse_of: :sent_diagnosed_needs

  # :experts
  has_many :expert_antennes, through: :experts, source: :antenne, inverse_of: :received_diagnosed_needs
  has_many :expert_institutions, through: :experts, source: :antenne_institution, inverse_of: :received_diagnosed_needs

  ## Scopes
  #
  scope :of_relay_or_expert, -> (relay_or_expert) { joins(:matches).merge(Match.of_relay_or_expert(relay_or_expert)) }

  scope :made_in, -> (date_range) do
    joins(:diagnosis)
      .where(diagnoses: { happened_on: date_range })
      .distinct
  end
  scope :ordered_for_interview, -> do
    left_outer_joins(:question, question: :theme)
      .order('themes.interview_sort_order')
      .order('questions.interview_sort_order')
  end

  scope :diagnosis_completed, -> do
    joins(:diagnosis)
      .merge(Diagnosis.completed)
  end

  scope :quo_not_taken_after_3_weeks, -> do
    by_status(:quo)
      .archived(false)
      .no_activity_after(3.weeks.ago)
  end
  scope :taken_not_done_after_3_weeks, -> do
    by_status(:taking_care)
      .archived(false)
      .no_activity_after(3.weeks.ago)
  end
  scope :rejected, -> do
    by_status(:not_for_me)
      .archived(false)
  end

  scope :no_activity_after, -> (date) do
    where.not("diagnosed_needs.updated_at > ?", date)
      .left_outer_joins(:matches)
      .where.not(matches: Match.where('updated_at > ?', date))
      .left_outer_joins(:feedbacks)
      .where.not(feedbacks: Feedback.where('updated_at > ?', date))
  end

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

  ## ActiveAdmin/Ransacker helpers
  #
  ransacker(:by_status, formatter: -> (value) {
    by_status(value).pluck(:id)
  }) { |parent| parent.table[:id] }

  ##
  #
  def to_s
    "#{company} : #{question}"
  end

  def last_activity_at
    dates = [updated_at, matches.pluck(:updated_at), feedbacks.pluck(:updated_at)].flatten
    dates.max
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
  def can_be_viewed_by?(role)
    if role.present? && advisor == role
      true
    else
      belongs_to_relay_or_expert?(role)
    end
  end

  def belongs_to_relay_or_expert?(role)
    relays.include?(role) || experts.include?(role)
  end

  ##
  #
  def contacted_persons
    (relays.map(&:user) + experts).uniq
  end
end
