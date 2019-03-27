# == Schema Information
#
# Table name: categories
#
#  id                   :bigint(8)        not null, primary key
#  interview_sort_order :integer
#  label                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Category < ApplicationRecord
  ## Associations
  #
  has_many :questions, inverse_of: :category

  ## Validations
  #
  validates :label, presence: true, uniqueness: true

  ## Through Associations
  #
  has_many :assistances, through: :questions, inverse_of: :category

  ## Scopes
  #
  scope :ordered_for_interview, -> { order(:interview_sort_order, :id) }

  ##
  #
  def to_s
    label
  end
end
