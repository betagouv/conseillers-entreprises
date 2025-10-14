# == Schema Information
#
# Table name: territories
#
#  id                 :bigint(8)        not null, primary key
#  bassin_emploi      :boolean          default(FALSE), not null
#  code_region        :integer
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  support_contact_id :bigint(8)
#
# Indexes
#
#  index_territories_on_code_region         (code_region) UNIQUE
#  index_territories_on_support_contact_id  (support_contact_id)
#

class Territory < ApplicationRecord
  ## Associations
  #
  has_and_belongs_to_many :communes, inverse_of: :territories
  include ManyCommunes

  belongs_to :support_contact, class_name: 'User', optional: true

  has_and_belongs_to_many :themes
  has_many :subjects, through: :themes, inverse_of: :territories
  has_many :landing_themes, through: :subjects, inverse_of: :theme_territories

  ## Through Associations
  #
  # :communes
  has_many :antennes, -> { distinct }, through: :communes, inverse_of: :territories
  has_many :advisors, -> { distinct }, through: :communes, inverse_of: :antenne_territories
  has_many :antenne_experts, -> { unscope(where: :deleted_at).distinct }, through: :communes, inverse_of: :antenne_territories
  has_many :direct_experts, -> { unscope(where: :deleted_at).distinct }, through: :communes, inverse_of: :territories

  has_many :facilities, through: :communes, inverse_of: :territories

  has_many :bassins_emploi, -> { distinct.bassins_emploi }, through: :communes, source: :territories

  # :facilities
  has_many :diagnoses, through: :facilities, inverse_of: :facility_territories
  has_many :needs, through: :facilities, inverse_of: :facility_territories
  has_many :matches, through: :facilities, inverse_of: :facility_territories
  has_many :companies, through: :facilities, inverse_of: :territories

  ## Scopes
  #
  scope :bassins_emploi, -> { where(bassin_emploi: true) }
  scope :regions, -> { where.not(code_region: nil) }

  scope :with_support, -> { where.not(support_contact_id: nil) }

  ##
  #
  def to_s
    name
  end

  def territorial_experts
    Expert.where(id: direct_experts)
      .or(Expert.where(id: antenne_experts).where(id: Expert.without_custom_communes)) # Experts of the antennes on this Territory, who don’t override their Antenne zone.
  end

  def all_experts
    territorial_experts
      .or(Expert.with_global_zone)
  end

  def self.ransackable_attributes(auth_object = nil)
    ["bassin_emploi", "code_region", "created_at", "id", "id_value", "name", "support_contact_id", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "advisors", "antenne_experts", "antennes", "bassins_emploi", "communes", "companies", "diagnoses", "direct_experts",
      "facilities", "matches", "needs", "regions", "support_contact"
    ]
  end
end
