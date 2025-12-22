# == Schema Information
#
# Table name: facilities
#
#  id                :bigint(8)        not null, primary key
#  code_effectif     :string
#  effectif          :float
#  insee_code        :string           not null
#  naf_code          :string
#  naf_code_a10      :string
#  naf_libelle       :string
#  nafa_codes        :string           default([]), is an Array
#  nature_activites  :string           default([]), is an Array
#  readable_locality :string
#  siret             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  company_id        :bigint(8)        not null
#  opco_id           :bigint(8)
#
# Indexes
#
#  index_facilities_on_company_id  (company_id)
#  index_facilities_on_opco_id     (opco_id)
#  index_facilities_on_siret       (siret) UNIQUE WHERE ((siret)::text <> NULL::text)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (opco_id => institutions.id)
#

class Facility < ApplicationRecord
  include WithEffectif
  include NafCode

  ## Associations
  #
  belongs_to :company, inverse_of: :facilities
  belongs_to :opco, -> { opco }, class_name: 'Institution', inverse_of: :facilities, optional: true
  has_many :advisors, -> { not_deleted }, class_name: 'User', inverse_of: :antenne

  has_many :diagnoses, inverse_of: :facility

  ## Validations
  #
  validates :siret, uniqueness: { allow_nil: true }
  validates :insee_code, presence: true

  ## “Through” Associations
  #
  # :diagnoses
  has_many :needs, through: :diagnoses, inverse_of: :facility
  has_many :matches, through: :diagnoses, inverse_of: :facility
  has_many :company_satisfactions, through: :needs, inverse_of: :facility

  accepts_nested_attributes_for :company

  before_create :sanitize_data

  scope :with_siret, -> do
    where.not(siret: nil).where.not(siret: '')
  end

  scope :for_contacts, -> (emails = []) do
    joins(company: :contacts).where(contacts: { email: emails })
  end

  # Cherche les établissements avec un code insee d'un département de la région
  scope :by_region, -> (region_code) do
    departements = DecoupageAdministratif::Departement.where(code_region: region_code)
    return none if departements.empty?

    code_size = departements.first.code.size
    where("LEFT(facilities.insee_code, ?) IN (?)", code_size, departements.map(&:code))
  end

  def commune_name
    # TODO : garder readable locality ou passer sur la gem pour afficher le nom ?
    readable_locality || insee_code
  end

  def all_nature_activites
    (nature_activites + [company.forme_exercice]).compact.uniq
  end

  def has_artisanale_activites
    all_nature_activites.any? { |a| ["ARTISANALE", "ARTISANALE_REGLEMENTEE", "INDEPENDANTE", "GESTION_DE_BIENS"].include?(a) } || nafa_codes.any?
  end

  def has_commerciale_activites
    all_nature_activites.any?{ |a| ["COMMERCIALE", "AGENT_COMMERCIAL", "INDEPENDANTE", "GESTION_DE_BIENS"].include?(a) }
  end

  def has_liberal_activities
    all_nature_activites.any? { |a| ["LIBERALE_REGLEMENTEE", "LIBERALE_NON_REGLEMENTEE", "INDEPENDANTE", "GESTION_DE_BIENS"].include?(a) }
  end

  # Si demande de Mayotte, tout est envoyé vers l'OPCO Akto
  def get_relevant_opco
    if region&.code == "06" # Mayotte
      Institution.opco.find_by(slug: 'opco-akto-mayotte') # OPCO Akto Mayotte
    else
      self.opco
    end
  end

  def region
    DecoupageAdministratif::Commune.find(insee_code).region
  end

  ##
  #
  def to_s
    "#{company.name} (#{commune_name})"
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "code_effectif", "created_at", "effectif", "id", "id_value", "naf_code", "insee_code",
      "naf_code_a10", "naf_libelle", "opco_id", "readable_locality", "siret", "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["advisors", "company", "diagnoses", "matches", "needs", "opco"]
  end

  private

  def sanitize_data
    self.naf_code = self.naf_code.delete('.') if self.naf_code.present?
  end
end
