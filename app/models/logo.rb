# == Schema Information
#
# Table name: logos
#
#  id            :bigint(8)        not null, primary key
#  filename      :string           not null
#  logoable_type :string           not null
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  logoable_id   :bigint(8)        not null
#
# Indexes
#
#  index_logos_on_logoable  (logoable_type,logoable_id)
#
class Logo < ApplicationRecord
  belongs_to :logoable, polymorphic: true

  validates :filename, :name, :logoable_type, :logoable_id, presence: true, allow_blank: false
  validates :logoable_type, inclusion: { in: [Institution, Cooperation].map(&:name) }

  def to_s
    name
  end

  # GlobalID serialization, to make polymorphic selection easier in ActiveAdmin
  def logoable_globalid
    self.logoable&.to_global_id
  end

  def logoable_globalid=(new_value)
    self.logoable = GlobalID.find(new_value)
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "filename", "id", "id_value", "logoable_id", "logoable_type", "name", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["logoable"]
  end
end
