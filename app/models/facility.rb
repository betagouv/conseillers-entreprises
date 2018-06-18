# frozen_string_literal: true

class Facility < ApplicationRecord
  NUMBER_PATTERN = '[0-9]{14}'

  belongs_to :company

  validates :company, :siret, :city_code, presence: true

  scope :in_territory, (->(territory) { where(city_code: territory.city_codes) })

  def to_s
    "#{company.name_short} (#{readable_locality})"
  end
end
