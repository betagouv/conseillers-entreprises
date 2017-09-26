# frozen_string_literal: true

class ExpertTerritory < ApplicationRecord
  belongs_to :expert
  belongs_to :territory

  validates :expert, :territory, presence: true
end
