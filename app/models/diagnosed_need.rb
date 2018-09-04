# frozen_string_literal: true

class DiagnosedNeed < ApplicationRecord
  belongs_to :diagnosis
  belongs_to :question

  has_many :matches, dependent: :destroy

  validates :diagnosis, presence: true
  validates :question, uniqueness: { scope: :diagnosis_id, allow_nil: true }

  before_create :copy_question_label

  scope :of_diagnosis, (-> (diagnosis) { where(diagnosis: diagnosis) })
  scope :of_question, (-> (question) { where(question: question) })
  scope :of_relay_or_expert, (-> (relay_or_expert) { joins(:matches).merge(Match.of_relay_or_expert(relay_or_expert)) })
  scope :with_at_least_one_expert_done, -> { joins(:matches).where(matches: { status: :done }).distinct }

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
