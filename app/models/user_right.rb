# == Schema Information
#
# Table name: user_rights
#
#  id         :bigint(8)        not null, primary key
#  category   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  antenne_id :bigint(8)
#  user_id    :bigint(8)        not null
#
# Indexes
#
#  index_user_rights_on_antenne_id                           (antenne_id)
#  index_user_rights_on_user_id                              (user_id)
#  index_user_rights_on_user_id_and_antenne_id_and_category  (user_id,antenne_id,category) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (antenne_id => antennes.id)
#  fk_rails_...  (user_id => users.id)
#
class UserRight < ApplicationRecord
  belongs_to :antenne, inverse_of: :user_rights, optional: true
  belongs_to :user, inverse_of: :user_rights

  enum :category, {
    manager: 0,
    admin: 1,
    national_referent: 2,
    main_referent: 3,
  }, prefix: true

  validates :user_id, uniqueness: { scope: [:category, :antenne_id] }
  validates :category, presence: true
  validate :manager_has_managed_antennes, :only_one_user_by_referent, :be_admin_to_be_referent

  private

  def manager_has_managed_antennes
    self.errors.add(:antenne_id, I18n.t('errors.manager_without_managed_antennes')) if (category_manager? && antenne.blank?)
  end

  def be_admin_to_be_referent
    if (category_national_referent? && !user.is_admin?) || (category_main_referent? && !user.is_admin?)
      self.errors.add(:category, I18n.t('errors.admin_for_referents'))
    end
  end

  def only_one_user_by_referent
    # Un seul user pour les referents nationaux et principaux car il sont utilisé dans les signatures de mails et comme contact par défaut
    if (category_national_referent? && UserRight.category_national_referent.count >= 1) ||
      (category_main_referent? && UserRight.category_main_referent.count >= 1)
      self.errors.add(:category, I18n.t('errors.one_user_for_referents'))
    end
  end
end
