class Relay < ApplicationRecord
  belongs_to :territory
  belongs_to :user
  has_many :matches, dependent: :nullify, inverse_of: :relay

  validates :territory, :user, presence: true
  validates :territory, uniqueness: { scope: :user }

  scope :of_user, (-> (user) { where(user: user) })
end
