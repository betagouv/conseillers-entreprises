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
  default_scope { order(:interview_sort_order, :id) }

  ##
  #
  def to_s
    label
  end
end
