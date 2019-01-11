# == Schema Information
#
# Table name: facilities
#
#  id                :bigint(8)        not null, primary key
#  naf_code          :string
#  readable_locality :string
#  siret             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  commune_id        :bigint(8)        not null
#  company_id        :bigint(8)
#
# Indexes
#
#  index_facilities_on_commune_id  (commune_id)
#  index_facilities_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (commune_id => communes.id)
#  fk_rails_...  (company_id => companies.id)
#

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
  class << self
    def siret_is_hardcoded_valid(siret)
      # https://fr.wikipedia.org/wiki/Système_d%27identification_du_répertoire_des_établissements
      # Pour des raisons historiques, les SIRET attribués aux établissements du groupe La Poste utilisent une autre formule de validation, et ne sont donc pas tous valides au sens de la formule de Luhn. Le groupe La Poste ayant le SIREN : 356000000, les SIRET suivant cette autre formule de validation sont de la forme 356000000XXXXX
      siret.match?(/356000000...../)
    end
  end

  ##
  #
  def to_s
    "#{company.name} (#{readable_locality || commune.insee_code})"
  end
end
