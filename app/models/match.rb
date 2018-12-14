# frozen_string_literal: true

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

  belongs_to :assistance_expert, foreign_key: :assistances_experts_id, inverse_of: :matches, required: false
  has_one :expert, through: :assistance_expert, inverse_of: :received_matches # TODO: Should be direct once we remove assistance_expert and use a HABTM instead
  has_one :assistance, through: :assistance_expert, inverse_of: :matches

  belongs_to :relay, required: false
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
  scope :not_viewed, (-> { where(expert_viewed_page_at: nil) })

  scope :of_diagnoses, (lambda do |diagnoses|
    joins(diagnosed_need: :diagnosis).where(diagnosed_needs: { diagnosis: diagnoses })
  end)
  scope :with_status, (-> (status) { where(status: status) })
  scope :updated_more_than_five_days_ago, (-> { where('updated_at < ?', 5.days.ago) })
  scope :needing_taking_care_update, (-> { with_status(:taking_care).updated_more_than_five_days_ago })

  scope :of_relay_or_expert, (lambda do |relay_or_expert|
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
  end)

  ##
  #
  def to_s
    "#{I18n.t('activerecord.models.match.one')} avec #{person}"
  end

  def status_closed?
    status_done? || status_not_for_me?
  end

  def status_description
    I18n.t("activerecord.attributes.match.statuses.#{status}")
  end

  def status_short_description
    I18n.t("activerecord.attributes.match.statuses_short.#{status}")
  end

  def expert_description
    "#{expert_full_name} (#{expert_institution_name})"
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
      update_columns taken_care_of_at: Time.now
    end

    if status_quo? && taken_care_of_at
      update_columns taken_care_of_at: nil
    end
  end

  def update_closed_at
    if status_closed? && !closed_at
      update_columns closed_at: Time.now
    end

    if (status_quo? || status_taking_care?) && closed_at
      update_columns closed_at: nil
    end
  end
end
