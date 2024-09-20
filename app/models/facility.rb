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
  has_many :company_satisfactions, through: :needs, inverse_of: :facility

  # :commune
  has_many :territories, through: :commune, inverse_of: :facilities
  has_many :regions, -> { regions }, through: :commune, source: :territories, inverse_of: :facilities

  accepts_nested_attributes_for :company

  before_create :sanitize_data

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

  def all_nature_activites
    (nature_activites + [company.forme_exercice]).uniq
  end

  def has_artisanale_activites
    all_nature_activites.any? { |a| ["ARTISANALE", "ARTISANALE_REGLEMENTEE"].include?(a) }
  end

  def has_commerciale_activites
    forme_exercice.present? && ["COMMERCIALE"].include?(forme_exercice)
  end

  def has_liberal_activities
    forme_exercice.present? && ["LIBERALE_REGLEMENTEE", "LIBERALE_NON_REGLEMENTEE"].include?(forme_exercice)
  end

  ##
  #
  def to_s
    "#{company.name} (#{commune_name})"
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "code_effectif", "commune_id", "company_id", "created_at", "effectif", "id", "id_value", "naf_code",
      "naf_code_a10", "naf_libelle", "opco_id", "readable_locality", "siret", "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["advisors", "commune", "company", "diagnoses", "matches", "needs", "opco", "territories", "regions"]
  end

  private

  def sanitize_data
    self.naf_code = self.naf_code.delete('.') if self.naf_code.present?
  end
end
