class Feedback < ApplicationRecord
  belongs_to :match

  def can_be_viewed_by?(role)
    self.match.can_be_viewed_by?(role)
  end
end
