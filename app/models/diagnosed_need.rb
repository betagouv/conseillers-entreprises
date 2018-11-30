# frozen_string_literal: true

class DiagnosedNeed < ApplicationRecord
  ## Associations
  #
  belongs_to :diagnosis, inverse_of: :diagnosed_needs
  belongs_to :question, inverse_of: :diagnosed_needs
  has_many :matches, dependent: :destroy, inverse_of: :diagnosed_need

  ## Validations
  #
  validates :diagnosis, presence: true
  validates :question, uniqueness: { scope: :diagnosis_id, allow_nil: true }

  ##
  #
  before_create :copy_question_label

  ## Through Associations
  #
  # :diagnosis
  has_one :visit, through: :diagnosis # TODO: should be removed once we merge the Visit and Diagnosis models
  has_one :facility, through: :diagnosis, inverse_of: :diagnosed_needs
  has_one :company, through: :diagnosis, inverse_of: :diagnosed_needs
  has_one :advisor, through: :diagnosis, inverse_of: :sent_diagnosed_needs

  # :matches
  has_many :experts, through: :matches, inverse_of: :received_diagnosed_needs
  has_many :relays, through: :matches
  has_many :feedbacks, through: :matches, inverse_of: :diagnosed_need

  # # :facility
  has_many :facility_territories, through: :facility, source: :territories, inverse_of: :diagnosed_needs

  # :experts
  has_many :experts_antennes, through: :experts, source: :antenne, inverse_of: :received_diagnosed_needs

  ## Scopes
  #
  scope :of_diagnosis, (-> (diagnosis) { where(diagnosis: diagnosis) })
  scope :of_question, (-> (question) { where(question: question) })
  scope :of_relay_or_expert, (-> (relay_or_expert) { joins(:matches).merge(Match.of_relay_or_expert(relay_or_expert)) })
  scope :sent_by, -> (users) {
    joins(diagnosis: [visit: :advisor])
      .where(diagnoses: { visits: { advisor: users } })
  }

  scope :with_at_least_one_expert_done, -> { done }

  scope :unsent, -> { left_outer_joins(:matches).where('matches.id IS NULL').distinct }
  scope :with_no_one_in_charge, -> { joins(:matches).where.not(matches: Match.where(status: [:done, :taking_care])).distinct }
  scope :abandoned, -> { joins(:matches).where.not(matches: Match.where(status: [:quo, :done, :taking_care])).distinct }
  scope :being_taken_care_of, -> { where(matches: Match.where(status: [:taking_care])).where.not(id: done) }
  scope :done, -> { where(matches: Match.where(status: [:done])) }

  scope :made_in, (lambda do |date_range|
    joins(diagnosis: :visit)
      .where(diagnoses: { visits: { happened_on: date_range } })
      .distinct
  end)
  scope :ordered_by_interview, -> do
    left_outer_joins(:question, question: :category)
      .order('categories.interview_sort_order')
      .order('questions.interview_sort_order')
  end

  ##
  #
  def to_s
    "#{company} : #{question}"
  end

  def status_synthesis
    matches_status = matches.pluck(:status).map(&:to_sym)

    if matches_status.empty?
      :quo
    elsif matches_status.include?(:done)
      :done
    elsif matches_status.include?(:taking_care)
      :taking_care
    elsif matches_status.all?{ |o| o == :not_for_me }
      :not_for_me
    else
      :quo
    end
  end

  def status_description
    I18n.t("activerecord.attributes.match.statuses.#{status_synthesis}")
  end

  def status_short_description
    I18n.t("activerecord.attributes.match.statuses_short.#{status_synthesis}")
  end

  ##
  #
  def can_be_viewed_by?(role)
    diagnosis.visit.can_be_viewed_by?(role) || belongs_to_relay_or_expert?(role)
  end

  def belongs_to_relay_or_expert?(role)
    relays.include?(role) || experts.include?(role)
  end

  ##
  #
  def contacted_persons
    (relays.map(&:user) + experts).uniq
  end

  private

  def copy_question_label
    self.question_label ||= question&.label
  end
end
