# == Schema Information
#
# Table name: logos
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Logo < ApplicationRecord
  has_and_belongs_to_many :landing_subjects, inverse_of: :logos
  belongs_to :institution, optional: true

  validates :filename, presence: true, allow_blank: false

  def to_s
    name
  end
end
