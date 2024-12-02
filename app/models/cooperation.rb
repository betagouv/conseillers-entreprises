# == Schema Information
#
# Table name: cooperations
#
#  id             :bigint(8)        not null, primary key
#  display_url    :boolean          default(FALSE)
#  mtm_campaign   :string
#  name           :string
#  url            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  institution_id :bigint(8)        not null
#
# Indexes
#
#  index_cooperations_on_institution_id  (institution_id)
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#
class Cooperation < ApplicationRecord
  ## Associations
  #
  belongs_to :institution, inverse_of: :cooperations
  has_many :cooperation_themes, dependent: :destroy, inverse_of: :cooperation
  has_many :themes, through: :cooperation_themes, inverse_of: :cooperations
  has_many :landings, dependent: :restrict_with_exception
  has_one :logo, dependent: :destroy, as: :logoable, inverse_of: :logoable

  ##
  #
  def to_s
    name
  end

  def self.ransackable_attributes(auth_object = nil)
    ["institution_id", "created_at", "name", "id", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["institution", "landings", "logo"]
  end
end
