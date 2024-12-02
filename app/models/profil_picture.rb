# == Schema Information
#
# Table name: profil_pictures
#
#  id         :bigint(8)        not null, primary key
#  filename   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)        not null
#
# Indexes
#
#  index_profil_pictures_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class ProfilPicture < ApplicationRecord
  belongs_to :user
  validates :filename, presence: true, allow_blank: false

  validates :user_id, uniqueness: true

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "filename", "id", "updated_at", "user_id"]
  end
end
