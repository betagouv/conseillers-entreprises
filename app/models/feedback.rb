# == Schema Information
#
# Table name: feedbacks
#
#  id          :bigint(8)        not null, primary key
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  expert_id   :bigint(8)
#  need_id     :bigint(8)
#  user_id     :bigint(8)
#
# Indexes
#
#  index_feedbacks_on_expert_id  (expert_id)
#  index_feedbacks_on_need_id    (need_id)
#  index_feedbacks_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (need_id => needs.id)
#  fk_rails_...  (user_id => users.id)
#

class Feedback < ApplicationRecord
  ## Associations
  #
  belongs_to :need, inverse_of: :feedbacks
  belongs_to :expert, inverse_of: :feedbacks, optional: true
  belongs_to :user, inverse_of: :feedbacks, optional: true

  ## Validations
  #
  validates :need, :description, presence: true
  validate :expert_or_user_author

  ##
  #
  def author
    expert || user
  end

  def notify!
    persons_to_notify.each do |person|
      UserMailer.delay.match_feedback(self, person)
    end
  end

  def persons_to_notify
    need.experts + [need.advisor] - [author]
  end

  private

  def expert_or_user_author
    unless expert.blank? ^ user.blank?
      errors.add(:base, "Author can be Expert or User, not both")
    end
  end
end
