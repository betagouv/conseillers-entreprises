# frozen_string_literal: true

class SelectedAssistanceExpert < ApplicationRecord
  belongs_to :diagnosed_need
  belongs_to :assistance_expert, foreign_key: :assistances_experts_id

  validates :diagnosed_need, :assistance_expert, presence: true

  scope :of_diagnoses, (proc do |diagnoses|
    joins(diagnosed_need: :diagnosis).where(diagnosed_needs: { diagnosis: diagnoses })
  end)
end
