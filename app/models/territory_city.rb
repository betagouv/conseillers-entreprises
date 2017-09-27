# frozen_string_literal: true

class TerritoryCity < ApplicationRecord
  CITY_CODE_FORMAT = /\A[0-9]{5}\z/

  belongs_to :territory

  validates :territory, presence: true
  validates :city_code, presence: true, uniqueness: { scope: :territory }, format: { with: CITY_CODE_FORMAT }
end
