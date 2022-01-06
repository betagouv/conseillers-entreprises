# == Schema Information
#
# Table name: feedbacks
#
#  id                :bigint(8)        not null, primary key
#  category          :enum             not null
#  description       :text
#  feedbackable_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  feedbackable_id   :bigint(8)
#  user_id           :bigint(8)
#
# Indexes
#
#  index_feedbacks_on_category                               (category)
#  index_feedbacks_on_feedbackable_type_and_feedbackable_id  (feedbackable_type,feedbackable_id)
#  index_feedbacks_on_user_id                                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Feedback < ApplicationRecord
  enum category: {
    need: 'need',
    reminder: 'reminder',
    solicitation: 'solicitation'
  }, _prefix: true

  ## Associations
  #
  belongs_to :feedbackable, polymorphic: true, touch: true
  belongs_to :user, inverse_of: :feedbacks

  ## Validations
  #
  validates :description, presence: true

  ##
  #

  def notify_for_need!
    return unless category_need?
    persons_to_notify.each do |person|
      UserMailer.match_feedback(self, person)&.deliver_later
    end
  end

  # Notify experts of this need and other feedbacks authors, but if the author's expert is in need experts,
  # don't send an email to their personal address
  def persons_to_notify
    # all the users and experts involved
    users_to_notify = ([self.need.advisor] + self.need.feedbacks.map(&:user)).uniq
    experts_to_notify = self.need.experts

    # prefer expert emails to individual users
    users_to_notify -= experts_to_notify.flat_map(&:users)

    # don’t notify the author themselves
    users_to_notify.delete(self.user)
    experts_to_notify -= self.user.experts

    # don’t notify experts who clicked “not for me”
    experts_to_notify.reject!{ |e| e.received_matches.find_by(need: self.need)&.status_not_for_me? }

    # mix users and experts
    users_to_notify + experts_to_notify
  end

  def need
    feedbackable if feedbackable_type == "Need"
  end

  def solicitation
    feedbackable if feedbackable_type == "Solicitation"
  end
end
