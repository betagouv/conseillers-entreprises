# == Schema Information
#
# Table name: categories
#
#  id         :bigint(8)        not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Category < ApplicationRecord
  ## Associations
  #
  has_and_belongs_to_many :institutions

  ## Validations
  #
  validates :title, presence: true, allow_blank: false

  ##
  #
  def to_s
    title
  end
end
