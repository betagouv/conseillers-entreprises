# == Schema Information
#
# Table name: matches
#
#  id               :bigint(8)        not null, primary key
#  archived_at      :datetime
#  closed_at        :datetime
#  sent_at          :datetime
#  status           :enum             default("quo"), not null
#  taken_care_of_at :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  expert_id        :bigint(8)        not null
#  need_id          :bigint(8)        not null
#  subject_id       :bigint(8)        not null
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
  belongs_to :expert, inverse_of: :received_matches
  belongs_to :subject, inverse_of: :matches

  ## Validations and Callbacks
  #
  validates :expert, uniqueness: { scope: :need_id }
  after_update :update_taken_care_of_at
  after_update :update_closed_at
  after_update :auto_close_other_pole_emploi_matches

  ## Through Associations
  #
  # :need
  has_one :diagnosis, through: :need, inverse_of: :matches
  has_one :facility, through: :need, inverse_of: :matches
  has_one :company, through: :need, inverse_of: :matches
  has_one :advisor, through: :need, inverse_of: :sent_matches
  has_one :solicitation, through: :diagnosis, inverse_of: :matches
  has_one :company_satisfaction, through: :need, inverse_of: :matches
  has_many :related_matches, through: :need, source: :matches

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

  scope :not_sent, -> { where(sent_at: nil) }

  scope :sent, -> { where.not(sent_at: nil) }

  scope :in_region, -> (region) { joins(:facility_regions).where(facility: { territories: region }) }

  scope :in_progress, -> do
    where(status: [:quo, :taking_care])
  end

  scope :with_exchange, -> do
    where(status: [:done, :done_no_help])
  end

  scope :done, -> do
    where(status: [:done, :done_no_help, :done_not_reachable, :not_for_me])
  end

  scope :with_status_done, -> do
    where(status: [:done, :done_no_help, :done_not_reachable])
  end

  scope :taken_care_of, -> do
    where(status: [:done, :done_no_help, :done_not_reachable, :taking_care])
  end

  scope :with_status_quo_active, -> do
    status_quo.where(created_at: Need::REMINDERS_DAYS[:abandon]&.days&.ago..)
  end

  scope :with_status_expired, -> do
    status_quo.where(created_at: ..Need::REMINDERS_DAYS[:abandon]&.days&.ago)
  end

  scope :by_antenne, -> (antenne_id) do
    joins(expert: :antenne).where(expert: { antenne_id: antenne_id })
  end

  # Pour ransacker, en admin
  scope :solicitation_created_at_gteq, -> (val) do
    joins(:solicitation).where('solicitations.created_at >= ?', val)
  end

  scope :solicitation_created_at_lteq, -> (val) do
    joins(:solicitation).where('solicitations.created_at <= ?', val)
  end

  scope :solicitation_mtm_campaign_cont, -> (query) {
    joins(:solicitation).merge(Solicitation.mtm_campaign_cont(query))
  }

  scope :solicitation_mtm_campaign_eq, -> (query) {
    joins(:solicitation).merge(Solicitation.mtm_campaign_eq(query))
  }

  scope :solicitation_mtm_campaign_start, -> (query) {
    joins(:solicitation).merge(Solicitation.mtm_campaign_start(query))
  }

  scope :solicitation_mtm_campaign_end, -> (query) {
    joins(:solicitation).merge(Solicitation.mtm_campaign_end(query))
  }

  def self.ransackable_scopes(auth_object = nil)
    [
      :sent, :solicitation_created_at_gteq, :solicitation_created_at_lteq,
      :solicitation_mtm_campaign_cont, :solicitation_mtm_campaign_eq, :solicitation_mtm_campaign_start, :solicitation_mtm_campaign_end
    ]
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

  def self.ransackable_attributes(auth_object = nil)
    [
      "archived", "archived_at", "closed_at", "created_at", "expert_id", "id", "id_value", "need_id", "sent_at",
      "status", "subject_id", "taken_care_of_at", "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "advisor", "advisor_antenne", "advisor_institution", "company", "company_satisfaction", "contacted_users",
      "diagnosis", "expert", "expert_antenne", "expert_institution", "facility", "facility_regions", "facility_territories",
      "need", "related_matches", "solicitation", "subject", "theme"
    ]
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

  def auto_close_other_pole_emploi_matches
    pole_emploi = Institution.find_by(slug: 'pole-emploi')
    return if pole_emploi.nil? || self.status != 'taking_care'
    other_pole_emploi_matches = self.need.matches.joins(:expert_institution)
      .where(expert: { antenne: Antenne.where(institution_id: pole_emploi.id) })
      .where.not(id: self.id)
    if self.expert_institution == pole_emploi && other_pole_emploi_matches.any?
      other_pole_emploi_matches.update_all(status: 'not_for_me')
    end
  end
end
