# == Schema Information
#
# Table name: qualifications
#
#  id               :bigint(8)        not null, primary key
#  details          :string
#  feedback         :text
#  qualified        :boolean          not null
#  qualified_at     :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  feedback_user_id :bigint(8)
#  solicitation_id  :bigint(8)        not null
#
# Indexes
#
#  index_qualifications_on_feedback_user_id  (feedback_user_id)
#  index_qualifications_on_solicitation_id   (solicitation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (feedback_user_id => users.id) ON DELETE => nullify
#  fk_rails_...  (solicitation_id => solicitations.id) ON DELETE => cascade
#
class Qualification < ApplicationRecord
  ## Associations
  #
  belongs_to :solicitation, inverse_of: :qualification
  belongs_to :feedback_user, class_name: 'User', inverse_of: :qualification_feedbacks, optional: true

  ## Validations
  #
  validates :qualified, inclusion: { in: [true, false] }
  validates :details, presence: true, if: -> { qualified == false }
  validates :solicitation_id, uniqueness: true

  def state = qualified ? :go : :stop

  def self.ransackable_associations(auth_object = nil)
    ["feedback_user", "solicitation"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "details", "feedback", "feedback_user_id", "id", "qualified", "qualified_at", "solicitation_id", "updated_at"]
  end
end
