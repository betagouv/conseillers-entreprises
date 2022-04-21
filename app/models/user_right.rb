# == Schema Information
#
# Table name: user_rights
#
#  id         :bigint(8)        not null, primary key
#  right      :enum             default("advisor"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  antenne_id :bigint(8)
#  user_id    :bigint(8)        not null
#
# Indexes
#
#  index_user_rights_on_antenne_id              (antenne_id)
#  index_user_rights_on_user_id                 (user_id)
#  index_user_rights_on_user_id_and_antenne_id  (user_id,antenne_id) UNIQUE
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
    advisor: 'advisor',
    admin: 'admin',
    manager: 'manager'
  }, _prefix: true

  validates :user_id, uniqueness: { scope: :antenne_id }
end
