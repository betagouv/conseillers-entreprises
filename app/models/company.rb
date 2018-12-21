# frozen_string_literal: true

class Company < ApplicationRecord
  ## Relations and Validations
  #
  has_many :contacts, inverse_of: :company
  has_many :facilities, inverse_of: :company

  ## Validations
  #
  validates :name, presence: true
  validates :siren, uniqueness: { allow_nil: true }

  ## Through Associations
  #
  has_many :visits, through: :facilities # TODO: should be removed once we merge the Visit and Diagnosis models
  has_many :diagnoses, through: :facilities, inverse_of: :company
  has_many :diagnosed_needs, through: :facilities, inverse_of: :company
  has_many :matches, through: :facilities, inverse_of: :company

  ## Scopes
  #
  scope :diagnosed_in, (lambda do |date_range|
    joins(facilities: [visits: :diagnosis])
    .where(facilities: { visits: { happened_on: date_range } })
    .distinct
  end)

  ##
  #
  def to_s
    name
  end

  def categorie_juridique
    CategorieJuridique.description(legal_form_code)
  end
end
