# == Schema Information
#
# Table name: logos
#
#  id            :bigint(8)        not null, primary key
#  filename      :string
#  logoable_type :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  logoable_id   :bigint(8)
#
# Indexes
#
#  index_logos_on_logoable  (logoable_type,logoable_id)
#
class Logo < ApplicationRecord
  belongs_to :logoable, polymorphic: true

  validates :filename, presence: true, allow_blank: false

  def to_s
    name
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "filename", "id", "id_value", "logoable_id", "logoable_type", "name", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["logoable"]
  end
end
