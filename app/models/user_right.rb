# == Schema Information
#
# Table name: user_rights
#
#  id                     :bigint(8)        not null, primary key
#  category               :integer          not null
#  rightable_element_type :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  rightable_element_id   :bigint(8)
#  user_id                :bigint(8)        not null
#
# Indexes
#
#  index_user_rights_on_rightable_element   (rightable_element_type,rightable_element_id)
#  index_user_rights_on_user_id             (user_id)
#  unique_category_rightable_element_index  (user_id,category,rightable_element_id,rightable_element_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UserRight < ApplicationRecord
  belongs_to :rightable_element, polymorphic: true, optional: true
  belongs_to :antenne, -> { joins(:user_rights).where(user_rights: { rightable_element_type: 'Antenne' }) }, class_name: 'Antenne', foreign_key: 'rightable_element_id', inverse_of: :user_rights, optional: true
  belongs_to :cooperation, -> { joins(:user_rights).where(user_rights: { rightable_element_type: 'Cooperation' }) }, class_name: 'Cooperation', foreign_key: 'rightable_element_id', inverse_of: :user_rights, optional: true
  belongs_to :territorial_zone, -> { joins(:user_rights).where(user_rights: { rightable_element_type: 'TerritorialZone' }) }, class_name: 'TerritorialZone', foreign_key: 'rightable_element_id', inverse_of: :user_rights, optional: true

  belongs_to :user, inverse_of: :user_rights

  enum :category, {
    manager: 0,
    admin: 1,
    national_referent: 2,
    main_referent: 3,
    cooperation_manager: 4,
    cooperations_referent: 5,
    territorial_referent: 6
  }, prefix: true

  FOR_ADMIN = %i[admin national_referent main_referent cooperations_referent territorial_referent].freeze

  scope :for_admin, -> { where(category: %i[admin national_referent main_referent cooperations_referent]) }

  validates :user_id, uniqueness: { scope: %i[category rightable_element_type rightable_element_id] }

  validates :category, presence: true
  validate :manager_has_managed_antennes, :cooperation_manager_has_managed_cooperation,
    :be_admin_to_be_referent, :only_one_user_by_referent, :territorial_referent_has_managed_region,
    :only_one_territorial_referent_per_region

  private

  def manager_has_managed_antennes
    self.errors.add(:rightable_element_id, I18n.t('errors.manager_without_managed_antennes')) if (category_manager? && (rightable_element.blank? || !rightable_element.is_a?(Antenne)))
  end

  def cooperation_manager_has_managed_cooperation
    self.errors.add(:rightable_element_id, I18n.t('errors.cooperation_manager_without_managed_cooperation')) if (category_cooperation_manager? && (rightable_element.blank? || !rightable_element.is_a?(Cooperation)))
  end

  def be_admin_to_be_referent
    if (FOR_ADMIN.include?(category) && !user.is_admin?)
      self.errors.add(:category, I18n.t('errors.admin_for_referents'))
    end
  end

  def only_one_user_by_referent
    # Un seul user pour les referents admins car ils sont utilisé dans les signatures de mails et comme contact par défaut
    if (category_national_referent? && UserRight.category_national_referent.count >= 1) ||
      (category_main_referent? && UserRight.category_main_referent.count >= 1) ||
      (category_cooperations_referent? && UserRight.category_cooperations_referent.count >= 1)
      self.errors.add(:category, I18n.t('errors.one_user_for_referents'))
    end
  end

  def territorial_referent_has_managed_region
    if category_territorial_referent? && (rightable_element.blank? || !rightable_element.is_a?(TerritorialZone) || rightable_element.zone_type != 'region')
      self.errors.add(:rightable_element_id, I18n.t('errors.territorial_referent_without_managed_region'))
    end
  end

  def only_one_territorial_referent_per_region
    return unless category_territorial_referent? && rightable_element.is_a?(TerritorialZone) && rightable_element.zone_type == 'region'

    existing_rights = UserRight.where(
      category: :territorial_referent,
      rightable_element_type: 'TerritorialZone',
      rightable_element_id: rightable_element.id
    )

    # Exclude current record if updating
    existing_rights = existing_rights.where.not(id: id) if persisted?

    if existing_rights.exists?
      self.errors.add(:rightable_element_id, I18n.t('errors.one_territorial_referent_per_region'))
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "created_at", "updated_at", "category", "id", "rightable_element_id", "rightable_element_type", "user_id"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "rightable_element", "user"
    ]
  end
end
