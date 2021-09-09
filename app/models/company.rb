# == Schema Information
#
# Table name: companies
#
#  id               :integer          not null, primary key
#  code_effectif    :string
#  date_de_creation :date
#  inscrit_rcs      :boolean
#  inscrit_rm       :boolean
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
  include Effectif
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

  def all_registres?
    inscrit_rcs && inscrit_rm
  end

  def none_registres?
    !inscrit_rcs && !inscrit_rm
  end
end
