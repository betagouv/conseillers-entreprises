# == Schema Information
#
# Table name: territories
#
#  id                 :bigint(8)        not null, primary key
#  bassin_emploi      :boolean          default(FALSE), not null
#  code_region        :integer
#  deployed_at        :datetime
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  support_contact_id :bigint(8)
#
# Indexes
#
#  index_territories_on_code_region         (code_region)
#  index_territories_on_support_contact_id  (support_contact_id)
#

class Territory < ApplicationRecord
  ## Associations
  #
  has_and_belongs_to_many :communes, inverse_of: :territories
  include ManyCommunes

  belongs_to :support_contact, class_name: 'User', optional: true

  ## Through Associations
  #
  # :communes
  has_many :antennes, -> { distinct }, through: :communes, inverse_of: :territories
  has_many :advisors, -> { distinct }, through: :communes, inverse_of: :antenne_territories
  has_many :antenne_experts, -> { distinct }, through: :communes, inverse_of: :antenne_territories
  has_many :direct_experts, -> { distinct }, through: :communes, inverse_of: :territories

  has_many :facilities, through: :communes, inverse_of: :territories

  has_many :bassins_emploi, -> { distinct.bassins_emploi }, through: :communes, source: :territories
  has_many :regions, -> { distinct.regions }, through: :communes, source: :territories, inverse_of: :regions

  # :facilities
  has_many :diagnoses, through: :facilities, inverse_of: :facility_territories
  has_many :needs, through: :facilities, inverse_of: :facility_territories
  has_many :matches, through: :facilities, inverse_of: :facility_territories
  has_many :companies, through: :facilities, inverse_of: :territories

  ## Scopes
  #
  scope :bassins_emploi, -> { where(bassin_emploi: true) }
  scope :regions, -> { where.not(code_region: nil) }
  scope :deployed_regions, -> { regions.where(arel_table[:deployed_at].lteq(Time.zone.now)) }

  scope :with_support, -> { where.not(support_contact_id: nil) }

  def self.deployed_codes_regions
    deployed_regions.pluck(:code_region)
  end

  ##
  #
  def to_s
    name
  end

  def deployed?
    deployed_at.present? && deployed_at < Time.zone.now
  end

  def all_experts
    Expert.where(id: direct_experts)
      .or(Expert.where(id: antenne_experts).where(id: Expert.without_custom_communes)) # Experts of the antennes on this Territory, who don’t override their Antenne zone.
      .or(Expert.with_global_zone)
  end
end
