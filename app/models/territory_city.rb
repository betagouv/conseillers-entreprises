# frozen_string_literal: true

class TerritoryCity < ApplicationRecord
  belongs_to :territory
  belongs_to :commune

  validates :territory, presence: true
  validates :commune, presence: true
end
