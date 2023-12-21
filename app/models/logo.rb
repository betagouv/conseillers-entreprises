# == Schema Information
#
# Table name: logos
#
#  id             :bigint(8)        not null, primary key
#  filename       :string
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  institution_id :bigint(8)
#
# Indexes
#
#  index_logos_on_institution_id  (institution_id)
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#
class Logo < ApplicationRecord
  belongs_to :institution, optional: true

  validates :filename, presence: true, allow_blank: false

  def to_s
    name
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "filename", "id", "id_value", "institution_id", "name", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["institution"]
  end
end
