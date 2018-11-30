# frozen_string_literal: true

class Relay < ApplicationRecord
  belongs_to :territory
  belongs_to :user
  has_many :matches, dependent: :nullify, inverse_of: :relay

  validates :territory, :user, presence: true
  validates :territory, uniqueness: { scope: :user }

  scope :of_user, (-> (user) { where(user: user) })

  def territory_diagnoses
    Diagnosis.only_active
      .includes(visit: [:advisor, facility: [:company]])
      .includes(diagnosed_needs: [:question, :matches])
      .in_territory(self.territory)
      .reverse_chronological
  end
end
