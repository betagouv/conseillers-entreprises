# frozen_string_literal: true

class AssistanceExpert < ApplicationRecord
  belongs_to :assistance
  belongs_to :expert
  has_many :matches, -> { ordered_by_status }, foreign_key: :assistances_experts_id, dependent: :nullify
end
