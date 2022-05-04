# == Schema Information
#
# Table name: communes
#
#  id         :bigint(8)        not null, primary key
#  insee_code :string
#
# Indexes
#
#  index_communes_on_insee_code  (insee_code) UNIQUE
#

class Commune < ApplicationRecord
  ## Constants
  #
  INSEE_CODE_FORMAT = /\A[0-9AB]{5}\z/

  ## Associations
  #
  has_and_belongs_to_many :territories, inverse_of: :communes
  has_and_belongs_to_many :bassins_emploi, -> { bassins_emploi }, class_name: 'Territory'
  has_and_belongs_to_many :regions, -> { regions }, class_name: 'Territory'

  has_many :facilities, inverse_of: :commune

  has_and_belongs_to_many :antennes, inverse_of: :communes
  has_and_belongs_to_many :direct_experts, class_name: 'Expert', inverse_of: :communes

  ## Validations
  #
  validates :insee_code, presence: true, uniqueness: true, format: { with: INSEE_CODE_FORMAT }

  ## “Through” Associations
  #
  has_many :antenne_experts, through: :antennes, source: :experts, inverse_of: :antenne_communes
  has_many :advisors, through: :antennes, inverse_of: :antenne_communes

  scope :by_region,  ->(region) { joins(:regions).where(regions: { id: region.id }) }

  ##
  #
  def all_experts
    # Direct or through Antennes; returns an ActiveRecord Relation rather than an array.
    Expert.where(id: direct_experts)
      .or(Expert.where(id: antenne_experts).where(id: Expert.without_custom_communes)) # Experts of the antennes on this Commune, who don’t override their Antenne zone.
      .or(Expert.with_global_zone)
  end

  ##
  #
  def to_s
    insee_code
  end
end
