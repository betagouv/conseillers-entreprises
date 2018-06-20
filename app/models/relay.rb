# frozen_string_literal: true

class Relay < ApplicationRecord
  belongs_to :territory
  belongs_to :user

  validates :territory, :user, presence: true
  validates :territory, uniqueness: { scope: :user }

  scope :of_user, (-> (user) { where(user: user) })
  scope :of_diagnosis_location, (lambda do |diagnosis|
    joins(territory: :territory_cities)
      .where(territories: { territory_cities: { city_code: diagnosis.visit.facility.city_code } })
  end)
end
