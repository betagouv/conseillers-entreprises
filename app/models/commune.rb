class Commune < ApplicationRecord
  INSEE_CODE_FORMAT = /\A[0-9AB]{5}\z/

  validates :insee_code, presence: true, uniqueness: true, format: { with: INSEE_CODE_FORMAT }

  has_many :territory_cities
  has_many :territories, through: :territory_cities
  has_many :facilities
end
