# == Schema Information
#
# Table name: cooperations
#
#  id                              :bigint(8)        not null, primary key
#  archived_at                     :datetime
#  display_pde_partnership_mention :boolean          default(FALSE)
#  display_url                     :boolean          default(FALSE)
#  mtm_campaign                    :string
#  name                            :string           not null
#  root_url                        :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  institution_id                  :bigint(8)        not null
#
# Indexes
#
#  index_cooperations_on_institution_id  (institution_id)
#  index_cooperations_on_name            (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#
class Cooperation < ApplicationRecord
  include Archivable

  ## Associations
  #
  belongs_to :institution, inverse_of: :cooperations
  has_many :landings, dependent: :restrict_with_exception, inverse_of: :cooperation
  has_many :solicitations, dependent: :restrict_with_exception, inverse_of: :cooperation

  has_many :cooperation_themes, dependent: :destroy, inverse_of: :cooperation
  has_many :specific_themes, through: :cooperation_themes, inverse_of: :cooperations, source: :theme

  has_many :landing_themes, through: :landings
  has_many :themes, through: :landing_themes
  has_many :subjects, through: :landing_themes

  has_many :user_rights, as: :rightable_element, dependent: :destroy, inverse_of: :rightable_element
  has_many :user_rights_managers, ->{ category_cooperation_manager }, as: :rightable_element, class_name: 'UserRight', inverse_of: :rightable_element

  has_one :logo, dependent: :destroy, as: :logoable, inverse_of: :logoable

  ## Hooks and Validations
  #
  auto_strip_attributes :name
  validates :name, presence: true, uniqueness: true

  ##
  #
  def to_s
    name
  end

  def archive!
    self.landings.update_all(archived_at: Time.zone.now)
    super
  end

  def unarchive!
    self.landings.update_all(archived_at: nil)
    super
  end

  def with_provenance_details?
    self.solicitations.pluck(:provenance_detail).compact_blank.uniq.any?
  end

  def self.ransackable_attributes(auth_object = nil)
    ["institution_id", "created_at", "name", "id", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["institution", "landings", "logo"]
  end
end
