# frozen_string_literal: true

class Facility < ApplicationRecord
  NUMBER_PATTERN = '[0-9]{14}'

  belongs_to :company

  validates :company, :siret, :postal_code, presence: true

  def to_s
    "#{company.name_short} (#{postal_code})"
  end
end
