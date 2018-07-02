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

  def territory_diagnoses
    Diagnosis.only_active
      .includes(visit: [:advisor, facility: [:company]])
      .includes(diagnosed_needs: [:question, :matches])
      .in_territory(self.territory)
      .reverse_chronological
  end

  def assigned_diagnoses
    Diagnosis.only_active
      .includes(visit: [facility: :company])
      .joins(:diagnosed_needs)
      .merge(DiagnosedNeed.of_relay(self))
      .merge(Match.with_status([:quo, :taking_care]))
      .order('visits.happened_on desc', 'visits.created_at desc')
      .distinct
  end
end
