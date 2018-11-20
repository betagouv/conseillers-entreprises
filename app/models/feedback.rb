class Feedback < ApplicationRecord
  ## Relations and Validations
  #
  belongs_to :match

  validates :match, :description, presence: true

  ##
  #
  def can_be_viewed_by?(role)
    self.match.can_be_viewed_by?(role)
  end
end
