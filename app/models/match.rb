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
#  diagnosed_need_id       :bigint(8)
#  experts_skills_id       :bigint(8)
#  relay_id                :bigint(8)
#
# Indexes
#
#  index_matches_on_diagnosed_need_id  (diagnosed_need_id)
#  index_matches_on_experts_skills_id  (experts_skills_id)
#  index_matches_on_relay_id           (relay_id)
#  index_matches_on_status             (status)
#
# Foreign Keys
#
#  fk_rails_...  (diagnosed_need_id => diagnosed_needs.id)
#  fk_rails_...  (experts_skills_id => experts_skills.id)
#  fk_rails_...  (relay_id => relays.id)
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
  belongs_to :diagnosed_need, counter_cache: true, inverse_of: :matches

  belongs_to :assistance_expert, foreign_key: :assistances_experts_id, inverse_of: :matches, optional: true
  has_one :expert, through: :assistance_expert, inverse_of: :received_matches # TODO: Should be direct once we remove assistance_expert and use a HABTM instead
  has_one :assistance, through: :assistance_expert, inverse_of: :matches

  belongs_to :relay, optional: true
  has_one :relay_user, through: :relay, source: :user, inverse_of: :relay_matches

  has_many :feedbacks, dependent: :destroy, inverse_of: :match

  ## Validations
  #
  validates :diagnosed_need, presence: true
  validates_with MatchValidator

  ## Through Associations
  #
  # :diagnosed_need
  has_one :diagnosis, through: :diagnosed_need, inverse_of: :matches
  has_one :facility, through: :diagnosed_need, inverse_of: :matches
  has_one :company, through: :diagnosed_need, inverse_of: :matches
  has_one :advisor, through: :diagnosed_need, inverse_of: :sent_matches
  has_many :related_matches, through: :diagnosed_need, source: :matches, inverse_of: :related_matches

  # :advisor
  has_one :advisor_antenne, through: :advisor, source: :antenne, inverse_of: :sent_matches
  has_one :advisor_institution, through: :advisor, source: :antenne_institution, inverse_of: :sent_matches

  # :expert
  has_one :expert_antenne, through: :expert, source: :antenne, inverse_of: :received_matches
  has_one :expert_institution, through: :expert, source: :antenne_institution, inverse_of: :received_matches

  # :facility
  has_many :facility_territories, through: :facility, source: :territories, inverse_of: :matches

  ## After Update
  #
  after_update :update_taken_care_of_at
  after_update :update_closed_at

  ## Scopes
  #
  scope :not_viewed, -> { where(expert_viewed_page_at: nil) }
  scope :of_diagnoses, -> (diagnoses) { where(diagnosed_need: DiagnosedNeed.where(diagnosis: diagnoses)) }
  scope :with_status, -> (status) { where(status: status) }

  scope :updated_more_than_five_days_ago, -> { where('matches.updated_at < ?', 5.days.ago) }

  scope :of_relay_or_expert, -> (relay_or_expert) do
    if relay_or_expert.is_a?(Enumerable)
      if relay_or_expert.empty?
        none
      else
        relations = relay_or_expert.map{ |item| of_relay_or_expert(item) }.compact
        relations.reduce(&:or)
      end
    elsif relay_or_expert.is_a?(Expert)
      left_outer_joins(:assistance_expert).where(assistances_experts: { expert: relay_or_expert })
    elsif relay_or_expert.is_a?(Relay)
      left_outer_joins(:assistance_expert).where(relay: relay_or_expert)
    else
      left_outer_joins(:assistance_expert).where(id: -1)
    end
  end

  scope :with_deleted_expert, -> do
    where(assistance_expert: nil)
      .where(relay: nil)
  end

  ##
  #
  def to_s
    "#{I18n.t('activerecord.models.match.one')} avec #{person_full_name}"
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

  def person
    expert || relay&.user
  end

  def person_full_name
    person&.full_name || expert_full_name
  end

  ##
  #
  def belongs_to_relay_or_expert?(role)
    role.present? && (expert == role || relay == role)
  end

  def can_be_viewed_by?(role)
    belongs_to_relay_or_expert?(role)
  end

  private

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
