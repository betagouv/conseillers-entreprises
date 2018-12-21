class AssistanceExpert < ApplicationRecord
  belongs_to :assistance
  belongs_to :expert
  has_many :matches, foreign_key: :assistances_experts_id, dependent: :nullify, inverse_of: :assistance_expert
end
