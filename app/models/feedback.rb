# == Schema Information
#
# Table name: feedbacks
#
#  id          :bigint(8)        not null, primary key
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  match_id    :bigint(8)
#
# Indexes
#
#  index_feedbacks_on_match_id  (match_id)
#
# Foreign Keys
#
#  fk_rails_...  (match_id => matches.id)
#

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
  has_one :diagnosed_need, through: :match, inverse_of: :feedbacks

  ##
  #
  def can_be_viewed_by?(role)
    self.match.can_be_viewed_by?(role)
  end
end
