# == Schema Information
#
# Table name: feedbacks
#
#  id                :bigint(8)        not null, primary key
#  description       :text
#  feedbackable_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  expert_id         :bigint(8)
#  feedbackable_id   :bigint(8)
#  user_id           :bigint(8)
#
# Indexes
#
#  index_feedbacks_on_expert_id                              (expert_id)
#  index_feedbacks_on_feedbackable_type_and_feedbackable_id  (feedbackable_type,feedbackable_id)
#  index_feedbacks_on_user_id                                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (user_id => users.id)
#

class Feedback < ApplicationRecord
  ## Associations
  #
  belongs_to :feedbackable, polymorphic: true, touch: true
  belongs_to :expert, inverse_of: :feedbacks, optional: true
  belongs_to :user, inverse_of: :feedbacks, optional: true

  ## Validations
  #
  validate :expert_or_user_author
  validates :description, presence: true

  ##
  #
  def author
    expert || user
  end

  def author=(person)
    if person.is_a? User
      self.user = person
    elsif person.is_a? Expert
      self.expert = person
    end
  end

  def notify_for_need!
    return if feedbackable_type != "Need"
    persons_to_notify.each do |person|
      UserMailer.match_feedback(self, person)&.deliver_later
    end
  end

  # Notify experts of this need and other feedbacks authors, but if the author's expert is in need experts,
  # don't send an email to their personal address
  def persons_to_notify
    experts_users = self.need.experts.flat_map(&:users)
    feedback_users = need.feedbacks.map(&:user)
    # remove users if their experts are already present in feedbacks authors
    feedback_users.filter! { |user| !experts_users.include?(user) }
    persons = (need.experts + [need.advisor] + feedback_users).uniq
    persons - [author] - author.experts
  end

  def need
    feedbackable if feedbackable_type == "Need"
  end

  def solicitation
    feedbackable if feedbackable_type == "Solicitation"
  end

  private

  def expert_or_user_author
    unless expert.blank? ^ user.blank?
      self.expert = nil
    end
  end
end
