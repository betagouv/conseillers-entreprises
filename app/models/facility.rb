# frozen_string_literal: true

class Facility < ApplicationRecord
  ## Associations
  #
  belongs_to :company, inverse_of: :facilities
  belongs_to :commune, inverse_of: :facilities

  has_many :visits
  has_many :diagnoses, through: :visits, inverse_of: :facility # TODO: should be direct once we merge the Visit and Diagnosis models

  ## Validations
  #
  validates :company, :commune, presence: true
  validates :siret, uniqueness: { allow_nil: true }

  ## “Through” Associations
  #
  # :diagnoses
  has_many :diagnosed_needs, through: :diagnoses, inverse_of: :facility
  has_many :matches, through: :diagnoses, inverse_of: :facility

  # :commune
  has_many :territories, through: :commune, inverse_of: :facilities

  ##
  #
  def to_s
    "#{company.name} (#{readable_locality || commune.insee_code})"
  end
end
