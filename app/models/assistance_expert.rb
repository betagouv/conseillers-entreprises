# frozen_string_literal: true

class AssistanceExpert < ApplicationRecord
  belongs_to :assistance
  belongs_to :expert
  has_many :selected_assistance_experts, foreign_key: :assistances_experts_id, dependent: :nullify

  scope :of_diagnosis, (->(diagnosis) { joins(:assistance).merge(Assistance.of_diagnosis(diagnosis)) })
  scope :of_city_code, (->(city_code) { joins(:expert).merge(Expert.of_city_code(city_code)) })
  scope :of_naf_code, (->(naf_code) { joins(expert: :institution).merge(Institution.of_naf_code(naf_code)) })
end
