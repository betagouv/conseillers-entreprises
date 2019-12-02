# == Schema Information
#
# Table name: themes
#
#  id                   :bigint(8)        not null, primary key
#  interview_sort_order :integer
#  label                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Theme < ApplicationRecord
  ## Associations
  #
  has_many :subjects, inverse_of: :theme

  ## Validations
  #
  validates :label, presence: true, uniqueness: true

  ## Through Associations
  #
  has_many :skills, through: :subjects, inverse_of: :theme
  has_many :needs, through: :subjects, inverse_of: :theme
  has_many :matches, through: :subjects, inverse_of: :theme
  has_many :institutions_subjects, through: :subjects, inverse_of: :theme

  ## Scopes
  #
  scope :ordered_for_interview, -> { order(:interview_sort_order, :id) }

  ##
  #
  def to_s
    label
  end
end
