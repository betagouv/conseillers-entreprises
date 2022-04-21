# == Schema Information
#
# Table name: user_rights
#
#  id         :bigint(8)        not null, primary key
#  right      :enum             default(NULL), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  antenne_id :bigint(8)
#  user_id    :bigint(8)        not null
#
# Indexes
#
#  index_user_rights_on_antenne_id                        (antenne_id)
#  index_user_rights_on_user_id                           (user_id)
#  index_user_rights_on_user_id_and_antenne_id_and_right  (user_id,antenne_id,right) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (antenne_id => antennes.id)
#  fk_rails_...  (user_id => users.id)
#
class UserRight < ApplicationRecord
  belongs_to :antenne, inverse_of: :user_rights, optional: true
  belongs_to :user, inverse_of: :user_rights

  enum right: {
    admin: 'admin',
    manager: 'manager'
  }, _prefix: true

  validates :user_id, uniqueness: { scope: [:right, :antenne_id] }
  validate :manager_has_managed_antennes

  before_validation :add_default_managed_antenne

  private

  def manager_has_managed_antennes
    self.errors.add(:antenne_id, I18n.t('errors.manager_without_managed_antennes')) if (right_manager? && antenne.blank?)
  end

  def add_default_managed_antenne
    self.antenne = user.antenne if (right_manager? && antenne.blank?)
  end
end
