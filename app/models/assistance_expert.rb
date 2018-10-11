# frozen_string_literal: true

class AssistanceExpert < ApplicationRecord
  belongs_to :assistance
  belongs_to :expert
  has_many :matches, -> { ordered_by_status }, foreign_key: :assistances_experts_id, dependent: :nullify

  scope :of_city_code, (-> (city_code) { joins(:expert).merge(Expert.of_city_code(city_code)) })
  scope :of_naf_code, (-> (naf_code) { joins(expert: :local_office).merge(LocalOffice.of_naf_code(naf_code)) })
end
