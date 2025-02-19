# == Schema Information
#
# Table name: companies
#
#  id               :integer          not null, primary key
#  code_effectif    :string
#  date_de_creation :date
#  effectif         :float
#  forme_exercice   :string
#  legal_form_code  :string
#  name             :string
#  siren            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_companies_on_siren  (siren) UNIQUE WHERE ((siren)::text <> NULL::text)
#

class Company < ApplicationRecord
  include WithEffectif
  include CategorieJuridique

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
  # has_many :territories, through: :facilities, inverse_of: :companies
  # has_many :facilities_regions, -> { regions }, through: :facilities, source: :territories, inverse_of: :companies

  ## Scopes
  #
  scope :diagnosed_in, -> (date_range) do
    joins(:diagnoses)
      .where(diagnoses: { happened_on: date_range })
      .distinct
  end

  scope :simple_effectif_eq, -> (query) do
    query = I18n.t(query.to_i, scope: 'range_to_code')
    where(code_effectif: query).distinct if query.present?
  end

  ##
  #
  def to_s
    name
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "code_effectif", "created_at", "date_de_creation", "effectif", "forme_exercice", "id",
      "id_value", "legal_form_code", "name", "siren", "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["facilities"]
  end
end
