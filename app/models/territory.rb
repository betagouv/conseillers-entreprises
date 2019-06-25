# == Schema Information
#
# Table name: territories
#
#  id            :bigint(8)        not null, primary key
#  bassin_emploi :boolean          default(FALSE), not null
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Territory < ApplicationRecord
  ## Associations
  #
  has_and_belongs_to_many :communes, inverse_of: :territories
  include ManyCommunes

  ## Through Associations
  #
  # :communes
  has_many :antennes, -> { distinct }, through: :communes, inverse_of: :territories
  has_many :advisors, -> { distinct }, through: :communes, inverse_of: :antenne_territories
  has_many :antenne_experts, -> { distinct }, through: :communes, inverse_of: :antenne_territories
  has_many :direct_experts, -> { distinct }, through: :communes, inverse_of: :territories

  has_many :facilities, through: :communes, inverse_of: :territories

  has_many :bassins_emploi, -> { distinct.bassins_emploi }, through: :communes, source: :territories
  has_many :regions, -> { distinct.regions }, through: :communes, source: :territories

  # :facilities
  has_many :diagnoses, through: :facilities, inverse_of: :facility_territories
  has_many :needs, through: :facilities, inverse_of: :facility_territories
  has_many :matches, through: :facilities, inverse_of: :facility_territories
  has_many :companies, through: :facilities, inverse_of: :territories

  ## Scopes
  #
  scope :bassins_emploi, -> { where(bassin_emploi: true) }
  scope :regions, -> { where(bassin_emploi: false) }

  ##
  #
  def to_s
    name
  end

  def all_experts
    Expert.where(id: direct_experts)
      .or(Expert.where(id: antenne_experts).where(id: Expert.without_custom_communes)) # Experts of the antennes on this Territory, who don’t override their Antenne zone.
      .or(Expert.with_global_zone)
  end
end
