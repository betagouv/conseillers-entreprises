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
    need_reminder: 'need_reminder',
    expert_reminder: 'expert_reminder',
    solicitation: 'solicitation'
  }, _prefix: true

  ## Associations
  #
  belongs_to :feedbackable, polymorphic: true, touch: true
  belongs_to :user, inverse_of: :feedbacks
  has_many :experts, through: :user, inverse_of: :feedbacks

  # Associations used for joins in scopes
  belongs_to :feedback_need, -> { where(feedbacks: { feedbackable_type: 'Need' }) }, class_name: 'Need', foreign_key: 'feedbackable_id', inverse_of: :feedbacks, optional: true
  belongs_to :feedback_solicitation, -> { where(feedbacks: { feedbackable_type: 'Solicitation' }) }, class_name: "Solicitation", foreign_key: 'feedbackable_id', inverse_of: :feedbacks, optional: true
  belongs_to :feedback_expert, -> { where(feedbacks: { feedbackable_type: 'Expert' }) }, class_name: 'Expert', foreign_key: 'feedbackable_id', inverse_of: :feedbacks, optional: true

  ## Validations
  #
  validates :description, presence: true

  ## Scopes
  #
  scope :for_need, -> { where(feedbackable_type: 'Need') }
  scope :for_solicitation, -> { where(feedbackable_type: 'Solicitation') }
  scope :for_expert, -> { where(feedbackable_type: 'Expert') }

  ## Ransack scopes
  #
  scope :subject_eq, -> (subject) { joins(feedback_need: :subject).where(needs: { subjects: subject }) }
  scope :theme_eq, -> (theme) { joins(feedback_need: { subject: :theme }).where(subjects: { themes: theme }) }
  scope :landing_eq, -> (landing) do
    joins(feedback_need: { diagnosis: { solicitation: :landing } }).where(diagnoses: { solicitations: { landings: landing } })
  end
  scope :mtm_campaign_cont, -> (query) do
    Feedback.joins(feedback_need: { diagnosis: :solicitation }).where("solicitations.form_info::json->>'mtm_campaign' ILIKE ?", "%#{query}%")
      .or(Feedback.joins(feedback_need: { diagnosis: :solicitation }).where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "%#{query}%"))
  end
  scope :mtm_campaign_eq, -> (query) do
    Feedback.joins(feedback_need: { diagnosis: :solicitation }).where('form_info @> ?', { pk_campaign: query }.to_json)
      .or(Feedback.joins(feedback_need: { diagnosis: :solicitation }).where('form_info @> ?', { mtm_campaign: query }.to_json))
  end
  scope :mtm_campaign_start, -> (query) do
    Feedback.joins(feedback_need: { diagnosis: :solicitation }).where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "#{query}%")
      .or(Feedback.joins(feedback_need: { diagnosis: :solicitation }).where("solicitations.form_info::json->>'mtm_campaign' ILIKE ?", "#{query}%"))
  end
  scope :mtm_campaign_end, -> (query) do
    Feedback.joins(feedback_need: { diagnosis: :solicitation }).where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "%#{query}")
      .or(Feedback.joins(feedback_need: { diagnosis: :solicitation }).where("solicitations.form_info::json->>'mtm_campaign' ILIKE ?", "%#{query}"))
  end
  scope :mtm_kwd_cont, -> (query) do
    Feedback.joins(feedback_need: { diagnosis: :solicitation }).where("solicitations.form_info::json->>'mtm_kwd' ILIKE ?", "%#{query}%")
      .or(Feedback.joins(feedback_need: { diagnosis: :solicitation }).where("solicitations.form_info::json->>'pk_kwd' ILIKE ?", "%#{query}%"))
  end
  scope :mtm_kwd_eq, -> (query) do
    Feedback.joins(feedback_need: { diagnosis: :solicitation }).where('form_info @> ?', { pk_kwd: query }.to_json)
      .or(Feedback.joins(feedback_need: { diagnosis: :solicitation }).where('form_info @> ?', { mtm_kwd: query }.to_json))
  end
  scope :mtm_kwd_start, -> (query) do
    Feedback.joins(feedback_need: { diagnosis: :solicitation }).where("solicitations.form_info::json->>'pk_kwd' ILIKE ?", "#{query}%")
      .or(Feedback.joins(feedback_need: { diagnosis: :solicitation }).where("solicitations.form_info::json->>'mtm_kwd' ILIKE ?", "#{query}%"))
  end
  scope :mtm_kwd_end, -> (query) do
    Feedback.joins(feedback_need: { diagnosis: :solicitation }).where("solicitations.form_info::json->>'pk_kwd' ILIKE ?", "%#{query}")
      .or(Feedback.joins(feedback_need: { diagnosis: :solicitation }).where("solicitations.form_info::json->>'mtm_kwd' ILIKE ?", "%#{query}"))
  end
  scope :need_created_at_gteq, -> (val) { joins(:feedback_need).where('needs.created_at >= ?', val) }
  scope :need_created_at_lteq, -> (val) { joins(:feedback_need).where('needs.created_at <= ?', val) }
  scope :user_antenne_eq, -> (antenne) { joins(:user).where(users: { antenne: antenne }) }
  scope :user_institution_eq, -> (institution) { joins(user: { antenne: :institution }).where(users: { institutions: institution }) }

  ##
  #
  def notify_for_need!
    return unless category_need?
    persons_to_notify.each do |person|
      MatchFeedbackEmailJob.set(wait: 1.minute).perform_later(self.id, person)
    end
  end

  # Notify experts of this need
  # don't send an email to their personal address
  def persons_to_notify
    users_and_experts_to_notify = if self.user.is_admin?
      self.need.matches.where(status: [:quo, :taking_care, :done_not_reachable]).map(&:expert)
    else
      self.need.matches.where(status: [:taking_care, :done_not_reachable]).map(&:expert)
    end

    # don’t notify the author themselves
    users_and_experts_to_notify -= self.user.experts

    # Notify the advisor only if he's not the author or the author is not an admin
    users_and_experts_to_notify << self.need.advisor if (!self.user.is_admin? && self.user != self.need.advisor)

    users_and_experts_to_notify
  end

  def need
    feedbackable if feedbackable_type == "Need"
  end

  def solicitation
    feedbackable if feedbackable_type == "Solicitation"
  end

  def expert
    feedbackable if feedbackable_type == "Expert"
  end

  def self.ransackable_attributes(auth_object = nil)
    ["category", "created_at", "description", "feedbackable_id", "feedbackable_type", "id", "id_value", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["feedbackable", "user"]
  end

  def self.ransackable_scopes(auth_object = nil)
    [
      :subject_eq, :theme_eq, :landing_eq, :mtm_campaign_cont, :mtm_campaign_eq, :mtm_campaign_start, :mtm_campaign_end,
      :need_created_at_gteq, :need_created_at_lteq, :user_antenne_eq, :user_institution_eq
    ]
  end
end
