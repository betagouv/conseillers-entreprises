# frozen_string_literal: true

class Facility < ApplicationRecord
  belongs_to :company

  validates :company, :siret, :postal_code, presence: true
end
