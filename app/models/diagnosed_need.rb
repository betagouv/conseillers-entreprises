# frozen_string_literal: true

class DiagnosedNeed < ApplicationRecord
  belongs_to :diagnosis
  belongs_to :question

  has_many :matches

  validates :diagnosis, presence: true

  scope :of_diagnosis, (-> (diagnosis) { where(diagnosis: diagnosis) })
  scope :of_question, (-> (question) { where(question: question) })
  scope :of_expert, (lambda do |expert|
    joins(:matches).merge(Match.of_expert(expert))
  end)
  scope :of_relay, (lambda do |relay|
    joins(:matches).merge(Match.of_relay(relay))
  end)
  scope :of_relay_or_expert, (-> (relay_or_expert) { joins(:matches).merge(Match.of_relay_or_expert(relay_or_expert)) })
  scope :with_at_least_one_expert_done, (lambda do
    where(id: Match.with_status(:done).select(:diagnosed_need_id))
  end)

  def can_be_viewed_by?(role)
    diagnosis.visit.can_be_viewed_by?(role) || belongs_to_relay_or_expert?(role)
  end

  def belongs_to_relay_or_expert?(role)
    matches.any?{ |match| match.belongs_to_relay_or_expert?(role) }
  end
end
