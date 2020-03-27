# == Schema Information
#
# Table name: badges
#
#  id         :bigint(8)        not null, primary key
#  color      :string           not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Badge < ApplicationRecord
  ## Associations
  #
  has_and_belongs_to_many :solicitations

  ## Validations
  #
  validates :title, :color, presence: true, allow_blank: false
end
