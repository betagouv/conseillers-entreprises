# == Schema Information
#
# Table name: questions
#
#  id                   :integer          not null, primary key
#  interview_sort_order :integer
#  label                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  category_id          :bigint(8)
#
# Indexes
#
#  index_questions_on_category_id  (category_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#

class Question < ApplicationRecord
  ## Associations
  #
  belongs_to :category, inverse_of: :questions

  has_many :assistances, dependent: :nullify, inverse_of: :question
  has_many :diagnosed_needs, dependent: :nullify, inverse_of: :question

  ## Validations
  #
  validates :category, presence: true

  ## Through Associations
  #
  # :diagnosed_needs
  has_many :diagnoses, through: :diagnosed_needs, inverse_of: :questions

  ## Scopes
  #
  default_scope { :ordered_for_interview }

  scope :ordered_for_interview, -> { order(:interview_sort_order, :id) }

  ##
  #
  def to_s
    label
  end
end
