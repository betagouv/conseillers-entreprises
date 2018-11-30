# frozen_string_literal: true

class AssistanceExpert < ApplicationRecord
  belongs_to :assistance
  belongs_to :expert
  has_many :matches, -> { ordered_by_date }, foreign_key: :assistances_experts_id, dependent: :nullify, inverse_of: :assistance_expert
end
