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
#  expert_id               :bigint(8)
#  need_id                 :bigint(8)        not null
#  skill_id                :bigint(8)
#
# Indexes
#
#  index_matches_on_expert_id  (expert_id)
#  index_matches_on_need_id    (need_id)
#  index_matches_on_skill_id   (skill_id)
#  index_matches_on_status     (status)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (need_id => needs.id)
#  fk_rails_...  (skill_id => skills.id)
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
  belongs_to :expert, inverse_of: :received_matches
  belongs_to :skill, inverse_of: :matches

  has_many :feedbacks, dependent: :destroy, inverse_of: :match

  ## Validations and Callbacks
  #
  validates :need, presence: true
  validates :expert, uniqueness: { scope: :need_id, allow_nil: true }
  before_save :copy_expert_info
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
  has_one :advisor_institution, through: :advisor, source: :institution, inverse_of: :sent_matches

  # :expert
  has_one :expert_antenne, through: :expert, source: :antenne, inverse_of: :received_matches
  has_one :expert_institution, through: :expert, source: :institution, inverse_of: :received_matches
  has_many :contacted_users, through: :expert, source: :users, inverse_of: :received_matches

  # :facility
  has_many :facility_territories, through: :facility, source: :territories, inverse_of: :matches

  # :skill
  has_one :subject, through: :skill, inverse_of: :matches

  # :subject
  has_one :theme, through: :subject, inverse_of: :matches

  ## Scopes
  #
  scope :not_viewed, -> { where(expert_viewed_page_at: nil) }

  scope :updated_more_than_five_days_ago, -> { where('matches.updated_at < ?', 5.days.ago) }

  scope :to_support, -> { joins(:skill).where(skills: { subject: Subject.support_subject }) }

  scope :with_deleted_expert, ->{ where(expert: nil) }

  scope :active, -> do
    joins(:need)
      .merge(Need.active)
      .where.not(status: :not_for_me)
  end

  scope :active_abandoned, -> do
    joins(:need)
      .merge(Need.active.abandoned)
      .where.not(status: :not_for_me)
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
  def can_be_viewed_by?(role)
    diagnosis.can_be_viewed_by?(role)
  end

  def can_be_modified_by?(role)
    role.present? && expert == role
  end

  private

  def copy_expert_info
    if expert
      self.expert_full_name = expert.full_name
      self.expert_institution_name = expert.antenne.name
    end
    if skill
      self.skill_title = skill.title
    end
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
