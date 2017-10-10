# frozen_string_literal: true

class TerritoryUser < ApplicationRecord
  belongs_to :territory
  belongs_to :user

  validates :territory, :user, presence: true
  validates :territory, uniqueness: { scope: :user }
end
