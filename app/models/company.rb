# == Schema Information
#
# Table name: companies
#
#  id              :integer          not null, primary key
#  code_effectif   :string
#  legal_form_code :string
#  name            :string
#  siren           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Company < ApplicationRecord
  include Effectif

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
  has_many :diagnoses, through: :facilities, inverse_of: :company
  has_many :needs, through: :facilities, inverse_of: :company
  has_many :matches, through: :facilities, inverse_of: :company
  has_many :territories, through: :facilities, inverse_of: :companies

  ## Scopes
  #
  scope :diagnosed_in, -> (date_range) do
    joins(:diagnoses)
      .where(diagnoses: { happened_on: date_range })
      .distinct
  end

  ##
  #
  def to_s
    name
  end

  def categorie_juridique
    CategorieJuridique.description(legal_form_code)
  end

  ##
  #
  attr_accessor :details
  def self.with_sirene_details(details)
    company = Company.find_or_initialize_by(siren: details[:siren])
    company.name = details[:denomination] || [details[:prenom_usuel], details[:nom], details[:nom_usage]].compact.join(' ')
    company.legal_form_code = details[:categorie_juridique]
    company.code_effectif = details[:tranche_effectifs]
    company.details = details
    company
  end
end
