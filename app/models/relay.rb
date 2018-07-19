# frozen_string_literal: true

class Relay < ApplicationRecord
  belongs_to :territory
  belongs_to :user
  has_many :matches, dependent: :nullify

  validates :territory, :user, presence: true
  validates :territory, uniqueness: { scope: :user }

  scope :of_user, (-> (user) { where(user: user) })
  scope :of_diagnosis_location, (lambda do |diagnosis|
    joins(territory: :territory_cities)
      .where(territories: { territory_cities: { city_code: diagnosis.visit.facility.city_code } })
  end)

  def territory_diagnoses
    Diagnosis.only_active
      .includes(visit: [:advisor, facility: [:company]])
      .includes(diagnosed_needs: [:question, :matches])
      .in_territory(self.territory)
      .reverse_chronological
  end
end
