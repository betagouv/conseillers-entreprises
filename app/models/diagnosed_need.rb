# frozen_string_literal: true

class DiagnosedNeed < ApplicationRecord
  belongs_to :diagnosis
  belongs_to :question

  has_many :selected_assistance_experts

  validates :diagnosis, presence: true

  scope :of_diagnosis, (->(diagnosis) { where(diagnosis: diagnosis) })
  scope :of_assistance_expert_id, (proc do |assistance_expert_id|
    joins(question: [assistances: :assistances_experts])
      .where(questions: { assistances: { assistances_experts: { id: assistance_expert_id } } })
  end)
end
