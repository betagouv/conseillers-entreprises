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
  has_and_belongs_to_many :landing_subjects, inverse_of: :logos
  belongs_to :institution, optional: true

  validates :filename, presence: true, allow_blank: false

  def to_s
    name
  end
end
