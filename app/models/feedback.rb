class Feedback < ApplicationRecord
  ## Associations
  #
  belongs_to :match, inverse_of: :feedbacks

  ## Validations
  #
  validates :match, :description, presence: true

  ## Through Associations
  #
  has_one :expert, through: :match, inverse_of: :feedbacks

  ##
  #
  def can_be_viewed_by?(role)
    self.match.can_be_viewed_by?(role)
  end
end
