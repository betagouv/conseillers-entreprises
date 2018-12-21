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

  has_many :relays
  has_many :relay_users, through: :relays, source: :user, inverse_of: :relay_territories # TODO: should be named :relays when we get rid of the Relay model and use a HABTM

  ## Through Associations
  #
  # :communes
  has_many :antennes, -> { distinct }, through: :communes, inverse_of: :territories
  has_many :advisors, -> { distinct }, through: :communes, inverse_of: :antenne_territories
  has_many :antenne_experts, -> { distinct }, through: :communes, inverse_of: :antenne_territories
  has_many :direct_experts, -> { distinct }, through: :communes, inverse_of: :territories

  has_many :facilities, through: :communes, inverse_of: :territories

  # :facilities
  has_many :diagnoses, through: :facilities, inverse_of: :facility_territories
  has_many :diagnosed_needs, through: :facilities, inverse_of: :facility_territories
  has_many :matches, through: :facilities, inverse_of: :facility_territories
  has_many :companies, through: :facilities, inverse_of: :territories

  ## Scopes
  #
  scope :bassins_emploi, -> { where(bassin_emploi: true) }

  ##
  #
  def to_s
    name
  end
end
