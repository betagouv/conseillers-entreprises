# == Schema Information
#
# Table name: skills
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
#  index_skills_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#

class Skill < ApplicationRecord
  ## Associations
  #
  belongs_to :question, inverse_of: :skills

  has_many :experts_skills, dependent: :destroy
  has_many :experts, through: :experts_skills, inverse_of: :skills # TODO should be direct once we remove the ExpertSkill model and use a HABTM
  has_many :matches, through: :experts_skills, inverse_of: :skill

  ## Validations
  #
  validates :title, :question, presence: true

  ## Through Associations
  #
  has_one :theme, through: :question, inverse_of: :skills

  ##
  #
  def to_s
    title
  end
end
