# == Schema Information
#
# Table name: relays
#
#  id           :bigint(8)        not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  territory_id :bigint(8)
#  user_id      :bigint(8)
#
# Indexes
#
#  index_relays_on_territory_id  (territory_id)
#  index_relays_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (territory_id => territories.id)
#  fk_rails_...  (user_id => users.id)
#

class Relay < ApplicationRecord
  belongs_to :territory
  belongs_to :user
  has_many :matches, dependent: :nullify, inverse_of: :relay

  validates :territory, :user, presence: true
  validates :territory, uniqueness: { scope: :user }

  scope :of_user, (-> (user) { where(user: user) })
end
