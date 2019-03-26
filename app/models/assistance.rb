# == Schema Information
#
# Table name: assistances
#
#  id          :bigint(8)        not null, primary key
#  description :text
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :bigint(8)        not null
#
# Indexes
#
#  index_assistances_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#

class Assistance < ApplicationRecord
  ## Associations
  #
  belongs_to :question, inverse_of: :assistances

  has_many :assistances_experts, dependent: :destroy
  has_many :experts, through: :assistances_experts, inverse_of: :assistances # TODO should be direct once we remove the AssistanceExpert model and use a HABTM
  has_many :matches, through: :assistances_experts, inverse_of: :assistance

  ## Validations
  #
  validates :title, :question, presence: true

  ## Through Associations
  #
  has_one :category, through: :question, inverse_of: :assistances

  ##
  #
  attr_accessor :filtered_assistances_experts

  ##
  #
  def to_s
    title
  end
end
