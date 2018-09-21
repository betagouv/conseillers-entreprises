# frozen_string_literal: true

class DiagnosedNeed < ApplicationRecord
  belongs_to :diagnosis
  belongs_to :question

  has_many :matches, -> { ordered_by_status }, dependent: :destroy

  validates :diagnosis, presence: true
  validates :question, uniqueness: { scope: :diagnosis_id, allow_nil: true }

  before_create :copy_question_label

  scope :of_diagnosis, (-> (diagnosis) { where(diagnosis: diagnosis) })
  scope :of_question, (-> (question) { where(question: question) })
  scope :of_relay_or_expert, (-> (relay_or_expert) { joins(:matches).merge(Match.of_relay_or_expert(relay_or_expert)) })
  scope :with_at_least_one_expert_done, -> { joins(:matches).where(matches: { status: :done }).distinct }
  scope :with_no_one_in_charge, -> { where.not(matches: Match.where(status: [:done, :taking_care])) }
  scope :done, -> { where(matches: Match.where(status: [:done])) }
  scope :being_taken_care_of, -> { where(matches: Match.where(status: [:taking_care])).where.not(id: done) }
  scope :made_in, (lambda do |date_range|
    joins(diagnosis: :visit)
      .where(diagnoses: { visits: { happened_on: date_range } })
      .uniq
  end)

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

  def can_be_viewed_by?(role)
    diagnosis.visit.can_be_viewed_by?(role) || belongs_to_relay_or_expert?(role)
  end

  def belongs_to_relay_or_expert?(role)
    matches.any?{ |match| match.belongs_to_relay_or_expert?(role) }
  end

  private

  def copy_question_label
    self.question_label ||= question&.label
  end
end
