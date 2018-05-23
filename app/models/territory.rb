# frozen_string_literal: true

class Territory < ApplicationRecord
  has_many :territory_cities, dependent: :destroy
  has_many :expert_territories
  has_many :experts, through: :expert_territories
  has_many :territory_users
  has_many :users, through: :territory_users

  accepts_nested_attributes_for :territory_cities

  scope :ordered_by_name, (-> { order(:name) })

  def to_s
    "#{id} : #{name}"
  end

  def city_codes
    territory_cities.pluck(:city_code)
  end

  def city_codes=(codes_raw)
    wanted_codes = codes_raw.split(/[,\s]/).delete_if(&:empty?)
    if wanted_codes.any? { |code| code !~ /[0-9AB]{5}/ }
      raise 'Invalid city codes'
    end

    existing_codes = city_codes

    codes_to_remove = existing_codes - wanted_codes
    territory_cities.where(city_code: codes_to_remove)
                    .destroy_all

    codes_to_add = wanted_codes - existing_codes
    codes_to_add.each{ |c|
      TerritoryCity.create(territory: self, city_code: c)
    }
  end
end
