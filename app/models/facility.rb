# == Schema Information
#
# Table name: facilities
#
#  id                :bigint(8)        not null, primary key
#  code_effectif     :string
#  effectif          :float
#  naf_code          :string
#  naf_code_a10      :string
#  naf_libelle       :string
#  readable_locality :string
#  siret             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  commune_id        :bigint(8)        not null
#  company_id        :bigint(8)        not null
#  opco_id           :bigint(8)
#
# Indexes
#
#  index_facilities_on_commune_id  (commune_id)
#  index_facilities_on_company_id  (company_id)
#  index_facilities_on_opco_id     (opco_id)
#  index_facilities_on_siret       (siret) UNIQUE WHERE ((siret)::text <> NULL::text)
#
# Foreign Keys
#
#  fk_rails_...  (commune_id => communes.id)
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (opco_id => institutions.id)
#

class Facility < ApplicationRecord
  include WithEffectif
  include NafCode

  ## Associations
  #
  belongs_to :company, inverse_of: :facilities
  belongs_to :commune, inverse_of: :facilities
  belongs_to :opco, -> { opco }, class_name: 'Institution', inverse_of: :facilities, optional: true
  has_many :advisors, -> { not_deleted }, class_name: 'User', inverse_of: :antenne

  has_many :diagnoses, inverse_of: :facility

  ## Validations
  #
  validates :siret, uniqueness: { allow_nil: true }

  ## “Through” Associations
  #
  # :diagnoses
  has_many :needs, through: :diagnoses, inverse_of: :facility
  has_many :matches, through: :diagnoses, inverse_of: :facility

  # :commune
  has_many :territories, through: :commune, inverse_of: :facilities

  accepts_nested_attributes_for :company

  scope :with_siret, -> do
    where.not(siret: nil).where.not(siret: '')
  end

  scope :for_contacts, -> (emails = []) do
    joins(company: :contacts).where(contacts: { email: emails })
  end

  ## insee_code / commune helpers
  # TODO: insee_code should be just a column in facility, and we should drop the Commune model entirely.
  #   In the meantime, fake it by delegating to commune.
  delegate :insee_code, to: :commune, allow_nil: true # commune can be nil in new facility models.
  def insee_code=(insee_code)
    return if insee_code.blank?
    self.commune = Commune.find_or_initialize_by(insee_code: insee_code)
    city_params = ApiGeo::Query.city_with_code(insee_code)
    self.readable_locality = "#{city_params['codesPostaux']&.first} #{city_params['nom']}"
  end

  def commune_name
    readable_locality || insee_code
  end

  ##
  #
  def to_s
    "#{company.name} (#{commune_name})"
  end
end
