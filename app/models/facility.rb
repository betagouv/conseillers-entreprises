# frozen_string_literal: true

class Facility < ApplicationRecord
  NUMBER_PATTERN = '[0-9]{14}'

  belongs_to :company
  belongs_to :commune
  has_many :visits
  has_many :diagnoses, through: :visits

  validates :company, :commune, presence: true
  validates :siret, uniqueness: { allow_nil: true }

  scope :in_territory, (-> (territory) { where(commune: territory.communes) })

  def to_s
    "#{company.name_short} (#{readable_locality || commune.insee_code})"
  end
end
