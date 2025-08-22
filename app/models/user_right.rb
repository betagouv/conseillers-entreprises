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

  ADMIN_ONLY_CATEGORIES = %i[admin national_referent main_referent cooperations_referent territorial_referent]
  SINGLETON_CATEGORIES = %i[national_referent main_referent cooperations_referent]

  scope :for_admin, -> { where(category: ADMIN_ONLY_CATEGORIES) }

  validates :user_id, uniqueness: { scope: %i[category rightable_element_type rightable_element_id] }

  validates :category, presence: true
  validate :manager_has_managed_antennes,
           :cooperation_manager_has_managed_cooperation,
           :be_admin_to_have_rights_for_admins,
           :only_one_user_by_referent,
           :territorial_referent_has_managed_region,
           :only_one_territorial_referent_per_region
           
  before_validation :create_territorial_zone_if_needed
  after_save :finalize_territorial_zone_link

  private

  def manager_has_managed_antennes
    return unless category_manager?
    return if rightable_element.is_a?(Antenne)

    errors.add(:rightable_element_id, I18n.t('errors.manager_without_managed_antennes'))
  end

  def cooperation_manager_has_managed_cooperation
    return unless category_cooperation_manager?
    return if rightable_element.is_a?(Cooperation)

    errors.add(:rightable_element_id, I18n.t('errors.cooperation_manager_without_managed_cooperation'))
  end

  def be_admin_to_have_rights_for_admins
    return if category_admin? # Skip validation if creating admin right because user is not admin yet
    return unless ADMIN_ONLY_CATEGORIES.include?(category&.to_sym)
    return if user.is_admin?

    errors.add(:category, I18n.t('errors.admin_for_referents'))
  end

  def only_one_user_by_referent
    return unless SINGLETON_CATEGORIES.include?(category&.to_sym)
    return unless existing_singleton_right_exists?

    errors.add(:category, I18n.t('errors.one_user_for_referents'))
  end

  def territorial_referent_has_managed_region
    return unless category_territorial_referent?
    return if valid_territorial_zone_region?

    errors.add(:rightable_element_id, I18n.t('errors.territorial_referent_without_managed_region'))
  end

  def only_one_territorial_referent_per_region
    return unless category_territorial_referent? && valid_territorial_zone_region?
    return unless existing_territorial_referent_for_region?

    errors.add(:rightable_element_id, I18n.t('errors.one_territorial_referent_per_region'))
  end

  def valid_territorial_zone_region?
    rightable_element.is_a?(TerritorialZone) && rightable_element.zone_type == 'region'
  end

  def existing_singleton_right_exists?
    UserRight.where(category: category)
      .where.not(id: id)
      .exists?
  end

  def existing_territorial_referent_for_region?
    query = UserRight.joins(:territorial_zone)
                     .where(category: :territorial_referent)
                     .where(territorial_zones: { zone_type: 'region', code: rightable_element.code })
    
    # Exclude current record only if it's persisted (has an ID)
    query = query.where.not(id: id) if persisted?
    
    query.exists?
  end

  def create_territorial_zone_if_needed
    return unless category_territorial_referent? && rightable_element_type == 'TerritorialZone'
    
    # If rightable_element_id is a region code (not a numeric ID), create the TerritorialZone
    if rightable_element_id.present? && rightable_element_id.to_s !~ /^\d+$/
      region_code = rightable_element_id.to_s
      
      # Check if TerritorialZone already exists for this region
      existing_tz = TerritorialZone.find_by(code: region_code, zone_type: 'region')
      
      if existing_tz
        # Use existing TerritorialZone
        self.rightable_element_id = existing_tz.id
      else
        # Create new TerritorialZone
        territorial_zone = TerritorialZone.create!(
          code: region_code,
          zone_type: 'region',
          zoneable_type: 'UserRight'
        )
        
        self.rightable_element_id = territorial_zone.id
        
        # Update zoneable_id after save
        @pending_territorial_zone = territorial_zone
      end
    end
  end

  def finalize_territorial_zone_link
    return unless @pending_territorial_zone
    
    @pending_territorial_zone.update!(zoneable_id: id)
    @pending_territorial_zone = nil
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
