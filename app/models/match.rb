# == Schema Information
#
# Table name: matches
#
#  id               :bigint(8)        not null, primary key
#  archived_at      :datetime
#  closed_at        :datetime
#  status           :enum             default("quo"), not null
#  taken_care_of_at :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  expert_id        :bigint(8)
#  need_id          :bigint(8)        not null
#  subject_id       :bigint(8)
#
# Indexes
#
#  index_matches_on_expert_id              (expert_id)
#  index_matches_on_expert_id_and_need_id  (expert_id,need_id) UNIQUE WHERE (expert_id <> NULL::bigint)
#  index_matches_on_need_id                (need_id)
#  index_matches_on_status                 (status)
#  index_matches_on_subject_id             (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (need_id => needs.id)
#  fk_rails_...  (subject_id => subjects.id)
#

class Match < ApplicationRecord
  include Archivable
  include RangeScopes

  ## Constants
  #
  enum status: {
    quo: 'quo',
    taking_care: 'taking_care',
    done: 'done',
    done_no_help: 'done_no_help',
    done_not_reachable: 'done_not_reachable',
    not_for_me: 'not_for_me'
  }, _prefix: true

  ## Associations
  #
  belongs_to :need, counter_cache: true, inverse_of: :matches, touch: true
  belongs_to :expert, inverse_of: :received_matches, optional: true
  belongs_to :subject, inverse_of: :matches, optional: true

  ## Validations and Callbacks
  #
  validates :expert, uniqueness: { scope: :need_id, allow_nil: true }
  after_update :update_taken_care_of_at
  after_update :update_closed_at

  ## Through Associations
  #
  # :need
  has_one :diagnosis, through: :need, inverse_of: :matches
  has_one :facility, through: :need, inverse_of: :matches
  has_one :company, through: :need, inverse_of: :matches
  has_one :advisor, through: :need, inverse_of: :sent_matches
  has_one :solicitation, through: :diagnosis, inverse_of: :matches
  has_one :company_satisfaction, through: :need, inverse_of: :matches
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
  has_many :facility_regions, -> { regions }, through: :facility, source: :territories, inverse_of: :matches

  # :subject
  has_one :theme, through: :subject, inverse_of: :matches

  ## Scopes
  #
  scope :updated_more_than_five_days_ago, -> { where('matches.updated_at < ?', 5.days.ago) }

  scope :to_support, -> { joins(:need).where(subject: Subject.support_subject) }

  scope :with_deleted_expert, ->{ where(expert: nil) }

  scope :sent, -> { where(id: joins(:diagnosis).merge(Diagnosis.step_completed)) }

  scope :in_region, -> (region) { joins(:facility_regions).where(facility: { territories: region }) }

  # Takes all needs.matches in the user antenne territory and when there is an expert of user institution notified
  scope :antenne_territory_matches, -> (antenne, start_date, end_date) do
    joins(need: { experts: { antenne: :institution }, facility: :commune })
      .merge(Need.antenne_territory_needs(antenne, start_date, end_date))
      .distinct
  end

  # Utilisé pour les mails de relance
  scope :active, -> do
    joins(:need)
      .merge(Need.active)
      .where.not(status: :not_for_me)
  end

  scope :in_progress, -> do
    where(status: [:quo, :taking_care])
  end

  scope :done, -> do
    where(status: [:done, :done_no_help, :done_not_reachable, :not_for_me])
  end

  scope :with_status_done, -> do
    where(status: [:done, :done_no_help, :done_not_reachable])
  end

  # Pour ransacker, en admin
  scope :solicitation_created_at_gteq_datetime, -> (val) do
    joins(:solicitation).where('solicitations.created_at >= ?', val)
  end

  scope :solicitation_created_at_lteq_datetime, -> (val) do
    joins(:solicitation).where('solicitations.created_at <= ?', val)
  end

  def self.ransackable_scopes(auth_object = nil)
    [:sent, :solicitation_created_at_gteq_datetime, :solicitation_created_at_lteq_datetime]
  end

  ##
  #
  def to_s
    "#{I18n.t('activerecord.models.match.one')} avec #{expert.full_name}"
  end

  def status_closed?
    status_done? || status_not_for_me? || status_done_no_help? || status_done_not_reachable?
  end

  DATE_PROPERTIES = {
    quo: :created_at,
    not_for_me: :closed_at,
    taking_care: :taken_care_of_at,
    done: :closed_at,
    done_no_help: :closed_at,
    done_not_reachable: :closed_at
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
    taking_care: %i[done done_no_help done_not_reachable quo],
    done: %i[quo],
    done_no_help: %i[quo],
    done_not_reachable: %i[quo]
  }

  def allowed_new_status
    ALLOWED_STATUS_TRANSITIONS[self.status.to_sym]
  end

  def additional_match?
    delay_after_first_match = (created_at - need.initial_matches_at)
    delay_after_first_match > 30.seconds
  end

  def expert_subject
    # The subject of the expert that was used for matching;
    # it might be nil: it can be removed, or the match can be created without it.
    expert&.experts_subjects&.find { |es| es.subject == self.subject }
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
