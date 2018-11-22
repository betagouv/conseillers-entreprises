class Feedback < ApplicationRecord
  ## Associations
  #
  belongs_to :match, inverse_of: :feedbacks

  ## Validations
  #
  validates :match, :description, presence: true

  ##
  #
  def can_be_viewed_by?(role)
    self.match.can_be_viewed_by?(role)
  end
end
