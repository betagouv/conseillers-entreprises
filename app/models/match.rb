# == Schema Information
#
# Table name: matches
#
#  id                      :bigint(8)        not null, primary key
#  closed_at               :datetime
#  expert_full_name        :string
#  expert_institution_name :string
#  expert_viewed_page_at   :datetime
#  skill_title             :string
#  status                  :integer          default("quo"), not null
#  taken_care_of_at        :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  experts_skills_id       :bigint(8)
#  need_id                 :bigint(8)
#
# Indexes
#
#  index_matches_on_experts_skills_id  (experts_skills_id)
#  index_matches_on_need_id            (need_id)
#  index_matches_on_status             (status)
#
# Foreign Keys
#
#  fk_rails_...  (experts_skills_id => experts_skills.id)
#  fk_rails_...  (need_id => needs.id)
#

class Match < ApplicationRecord
  ##
  #
  audited only: :status

  ## Constants
  #
  enum status: { quo: 0, taking_care: 1, done: 2, not_for_me: 3 }, _prefix: true

  ## Associations
  #
  belongs_to :need, counter_cache: true, inverse_of: :matches

  belongs_to :expert_skill, foreign_key: :experts_skills_id, inverse_of: :matches, optional: true
  has_one :expert, through: :expert_skill, inverse_of: :received_matches # TODO: Should be direct once we remove expert_skill and use a HABTM instead
  has_one :skill, through: :expert_skill, inverse_of: :matches

  has_many :feedbacks, dependent: :destroy, inverse_of: :match

  ## Validations and Callbacks
  #
  validates :need, presence: true
  validates :expert_skill, uniqueness: { scope: :need_id, allow_nil: true }
  before_create :copy_expert_info
  after_update :update_taken_care_of_at
  after_update :update_closed_at

  ## Through Associations
  #
  # :need
  has_one :diagnosis, through: :need, inverse_of: :matches
  has_one :facility, through: :need, inverse_of: :matches
  has_one :company, through: :need, inverse_of: :matches
  has_one :advisor, through: :need, inverse_of: :sent_matches
  has_many :related_matches, through: :need, source: :matches, inverse_of: :related_matches

  # :advisor
  has_one :advisor_antenne, through: :advisor, source: :antenne, inverse_of: :sent_matches
  has_one :advisor_institution, through: :advisor, source: :antenne_institution, inverse_of: :sent_matches

  # :expert
  has_one :expert_antenne, through: :expert, source: :antenne, inverse_of: :received_matches
  has_one :expert_institution, through: :expert, source: :antenne_institution, inverse_of: :received_matches

  # :facility
  has_many :facility_territories, through: :facility, source: :territories, inverse_of: :matches

  ## Scopes
  #
  scope :not_viewed, -> { where(expert_viewed_page_at: nil) }
  scope :with_status, -> (status) { where(status: status) }

  scope :updated_more_than_five_days_ago, -> { where('matches.updated_at < ?', 5.days.ago) }

  scope :of_expert, -> (expert) { # TODO: remove when we get rid of :expert_skill
    joins(:expert_skill).where(experts_skills: { expert: expert })
  }

  scope :to_support, -> { joins(:skill).where(skills: { subject: Subject.support_subject }) }

  scope :with_deleted_expert, -> do
    where(expert_skill: nil)
  end

  ##
  #
  def to_s
    "#{I18n.t('activerecord.models.match.one')} avec #{expert_full_name}"
  end

  def status_closed?
    status_done? || status_not_for_me?
  end

  include StatusHelper::StatusDescription

  DATE_PROPERTIES = {
    quo: :created_at,
    not_for_me: :closed_at,
    taking_care: :taken_care_of_at,
    done: :closed_at
  }

  def status_date
    property = DATE_PROPERTIES[self.status.to_sym]
    if property
      date = self.send(property)
      I18n.l(date, format: :short)
    end
  end

  ALLOWED_STATUS_TRANSITIONS = {
    quo: %i[not_for_me taking_care],
    not_for_me: %i[quo],
    taking_care: %i[quo done],
    done: %i[quo]
  }

  def allowed_new_status
    ALLOWED_STATUS_TRANSITIONS[self.status.to_sym]
  end

  def expert_full_role
    "#{expert_full_name} - #{expert_institution_name}"
  end

  ##
  #
  def belongs_to_expert?(role)
    role.present? && expert == role
  end

  def can_be_viewed_by?(role)
    belongs_to_expert?(role)
  end

  private

  def copy_expert_info
    self.expert_full_name = expert_skill.expert.full_name
    self.expert_institution_name = expert_skill.expert.antenne.name
    self.skill_title = expert_skill.skill.title
  end

  def update_taken_care_of_at
    if (status_taking_care? || status_closed?) && !taken_care_of_at
      update_columns taken_care_of_at: Time.zone.now
    end

    if status_quo? && taken_care_of_at
      update_columns taken_care_of_at: nil
    end
  end

  def update_closed_at
    if status_closed? && !closed_at
      update_columns closed_at: Time.zone.now
    end

    if (status_quo? || status_taking_care?) && closed_at
      update_columns closed_at: nil
    end
  end
end
