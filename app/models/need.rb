# == Schema Information
#
# Table name: needs
#
#  id                      :bigint(8)        not null, primary key
#  abandoned_email_sent    :boolean          default(FALSE)
#  archived_at             :datetime
#  content                 :text
#  matches_count           :integer
#  satisfaction_email_sent :boolean          default(FALSE), not null
#  status                  :enum             default("diagnosis_not_complete"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  diagnosis_id            :bigint(8)        not null
#  subject_id              :bigint(8)        not null
#
# Indexes
#
#  index_needs_on_archived_at                  (archived_at)
#  index_needs_on_diagnosis_id                 (diagnosis_id)
#  index_needs_on_status                       (status)
#  index_needs_on_subject_id                   (subject_id)
#  index_needs_on_subject_id_and_diagnosis_id  (subject_id,diagnosis_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (diagnosis_id => diagnoses.id)
#  fk_rails_...  (subject_id => subjects.id)
#

class Need < ApplicationRecord
  ##
  #
  include Archivable
  include RangeScopes

  enum status: {
    diagnosis_not_complete: 'diagnosis_not_complete',
      quo: 'quo',
      taking_care: 'taking_care',
      done: 'done',
      done_no_help: 'done_no_help',
      done_not_reachable: 'done_not_reachable',
      not_for_me: 'not_for_me'
  }, _prefix: true

  ## Associations
  #
  belongs_to :diagnosis, inverse_of: :needs, touch: true
  belongs_to :subject, inverse_of: :needs
  has_many :matches, dependent: :destroy, inverse_of: :need
  has_many :feedbacks, -> { where(category: :need) }, dependent: :destroy, as: :feedbackable, inverse_of: :feedbackable
  has_many :reminder_feedbacks, -> { where(category: :need_reminder) }, class_name: :Feedback, dependent: :destroy, as: :feedbackable, inverse_of: :feedbackable
  has_many :reminders_actions, inverse_of: :need, dependent: :destroy
  has_one :company_satisfaction, dependent: :destroy, inverse_of: :need
  has_many :institution_filters, dependent: :destroy, as: :institution_filtrable, inverse_of: :institution_filtrable
  has_many :badge_badgeables, as: :badgeable
  has_many :badges, through: :badge_badgeables, after_add: :touch_after_badges_update, after_remove: :touch_after_badges_update

  ## Validations
  #
  validates :subject, uniqueness: { scope: :diagnosis_id }

  accepts_nested_attributes_for :matches, allow_destroy: true
  accepts_nested_attributes_for :institution_filters, allow_destroy: false

  ## Callbacks
  #
  after_touch :update_status

  ## Through Associations
  #
  # :diagnosis
  has_one :facility, through: :diagnosis, inverse_of: :needs
  has_one :company, through: :diagnosis, inverse_of: :needs
  has_one :solicitation, through: :diagnosis, inverse_of: :needs
  has_one :advisor, through: :diagnosis, inverse_of: :sent_needs
  has_one :visitee, through: :diagnosis, inverse_of: :needs

  # :matches
  has_many :experts, -> { distinct }, through: :matches, inverse_of: :received_needs

  # :facility
  has_many :facility_territories, through: :facility, source: :territories, inverse_of: :needs
  has_many :facility_regions, -> { regions }, through: :facility, source: :territories, inverse_of: :matches

  # :advisor
  has_one :advisor_antenne, through: :advisor, source: :antenne, inverse_of: :sent_needs
  has_one :advisor_institution, through: :advisor, source: :institution, inverse_of: :sent_needs

  # :experts
  has_many :expert_antennes, through: :experts, source: :antenne, inverse_of: :received_needs
  has_many :expert_institutions, through: :experts, source: :institution, inverse_of: :received_needs
  has_many :contacted_users, through: :experts, source: :users, inverse_of: :received_needs

  # :subject
  has_one :theme, through: :subject, inverse_of: :needs

  ## Scopes
  #
  NO_ACTIVITY_DELAY = 14.days
  ARCHIVE_DELAY = 6.months
  REMINDERS_DAYS = {
    poke: 7,
    recall: 14,
    last_chance: 21,
    abandon: 45
  }

  scope :ordered_for_interview, -> do
    left_outer_joins(:subject)
      .merge(Subject.ordered_for_interview)
  end

  scope :diagnosis_completed, -> { where.not(status: :diagnosis_not_complete) }

  scope :reminders_to, -> (action) do
    if action == :archive
      query1 = diagnosis_completed
        .archived(false)
        .in_reminders_range(action)
        .with_matches_only_in_status([:quo, :not_for_me])

      query2 = diagnosis_completed
        .archived(false)
        .status_not_for_me

      query1.or(query2)
    else # :poke, :recall and :last_chance
      diagnosis_completed
        .archived(false)
        .in_reminders_range(action)
        .status_quo
        .without_action(action)
    end
  end

  scope :without_action, -> (category) do
    subquery = Need.unscoped
      .joins(:reminders_actions)
      .where(reminders_actions: { category: category })
    where.not(id: subquery)
  end

  scope :received_by, -> (user_id) do
    joins(:contacted_users).where(users: { id: user_id })
  end

  def self.reminders_range(action)
    index = REMINDERS_DAYS.keys.index(action)
    Range.new(REMINDERS_DAYS.values[index + 1]&.days&.ago, REMINDERS_DAYS.values[index].days.ago)
  end

  scope :in_reminders_range, -> (action) {
    range = reminders_range(action)
    matches_created_at(range)
  }

  scope :matches_created_at, -> (range) {
    needs_in_range = Need.unscoped
      .joins(:matches)
      .where(matches: { created_at: range })
    # put it in a subquery to avoid duplicate rows, or requiring the join if this scope is composed with others
    where(id: needs_in_range)
  }

  scope :min_closed_at, -> (range) do
    joins(:matches)
      .merge(Match.status_done)
      .group(:id)
      .having("MIN(matches.closed_at) BETWEEN ? AND ?", range.begin, range.end)
  end

  # For Reminders, find Needs without taking care since NO_ACTIVITY_DELAY
  scope :no_activity, -> { joins(:matches).where("matches.created_at < ?", NO_ACTIVITY_DELAY.ago) }

  scope :abandoned, -> { where(abandoned_email_sent: true) }

  scope :not_abandoned, -> { where(abandoned_email_sent: false) }

  scope :with_some_matches_in_status, -> (status) do
    # status can be an array
    needs_with_matches = Need.unscoped
      .joins(:matches)
      .where(matches: Match.unscoped.where(status: status))
    # put it in a subquery to avoid duplicate rows, or requiring the join if this scope is composed with others
    where(id: needs_with_matches)
  end

  scope :with_matches_only_in_status, -> (status) do
    # status can be an array
    needs_with_matches = Need.unscoped
      .left_outer_joins(:matches)
      .where.not(matches: Match.unscoped.where.not(status: status))
    # put it in a subquery to avoid duplicate rows, or requiring the join if this scope is composed with others
    where(id: needs_with_matches)
  end

  # Utilisé pour les mails de relance
  scope :active, -> do
    archived(false)
      .with_matches_only_in_status([:quo, :taking_care, :not_for_me])
      .with_some_matches_in_status([:quo, :taking_care])
  end

  scope :without_exchange, -> do
    where(status: [:not_for_me, :done_not_reachable, :quo])
  end

  scope :for_reminders, -> do
    where(status: [:quo, :done_no_help, :done_not_reachable])
  end

  scope :with_exchange, -> do
    where(status: [:taking_care, :done, :done_no_help])
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

  scope :quo_active, -> do
    range = Range.new(Need::REMINDERS_DAYS[:abandon]&.days&.ago, nil)
    status_quo.matches_created_at(range)
  end

  scope :quo_abandoned, -> do
    range = Range.new(nil, Need::REMINDERS_DAYS[:abandon]&.days&.ago)
    status_quo.matches_created_at(range)
  end

  scope :for_facility, -> (facility) do
    joins(diagnosis: :facility).where(diagnoses: { facility: facility })
  end

  scope :with_siret, -> do
    joins(diagnosis: :facility).merge(Facility.with_siret)
  end

  scope :for_emails_and_sirets, -> (emails, sirets = []) do
    Need.diagnosis_completed.joins(:diagnosis, :solicitation, :facility).scoping do
      Need.where(diagnosis: { solicitations: { email: emails } })
        .or(Need.where(diagnosis: { facilities: { siret: sirets.compact } }))
    end
  end

  scope :in_antenne_perimeters, -> (antenne) do
    Need.where(id: antenne.perimeter_received_needs)
  end

  scope :by_region, -> (region) do
    joins(facility: :commune).merge(Commune.by_region(region))
  end

  scope :in_antennes_perimeters, -> (antennes) do
    Need.where(id: antennes.map(&:perimeter_received_needs).flatten)
  end

  ## Search
  #
  scope :omnisearch, -> (query) do
    if query.present?
      eager_load(:subject, :visitee, :company, :facility)
        .where(
          arel_content_contains(query)
          .or(arel_subject_contains(query)
          .or(arel_contact_contains(query)
          .or(arel_company_contains(query)
          .or(arel_facility_contains(query)))))
        )
    end
  end

  scope :arel_content_contains, -> (query) do
    arel_table[:content].matches("%#{query}%")
  end

  def self.arel_subject_contains(query)
    Subject.arel_table[:label].matches("%#{query}%")
  end

  def self.arel_contact_contains(query)
    Contact.arel_table[:full_name].matches("%#{query}%").or(
      Contact.arel_table[:email].matches("%#{query}%")
    )
  end

  def self.arel_company_contains(query)
    Company.arel_table[:name].matches("%#{query}%").or(
      Company.arel_table[:siren].matches("%#{query}%")
    )
  end

  def self.arel_facility_contains(query)
    Facility.arel_table[:readable_locality].matches("%#{query}%")
  end

  ##
  #
  def to_s
    "#{company} : #{subject}"
  end

  def initial_matches_at
    matches.pluck(:created_at).min
  end

  def no_activity?
    updated_at < NO_ACTIVITY_DELAY.ago
  end

  def has_action?(action)
    reminders_actions.find_by(category: action).present?
  end

  def quo_experts
    Expert.joins(:received_matches).merge(matches.status_quo)
  end

  def update_status
    self.matches.reload # Make sure the matches are fresh from DB; see #1421
    new_status = computed_status
    self.update(status: new_status)
  end

  def display_time
    solicitation&.created_at || diagnosis.created_at
  end

  def display_date
    display_time.to_date
  end

  def computed_status
    matches_status = matches.pluck(:status).map(&:to_sym)

    # no matches yet
    if matches.empty? || !diagnosis.step_completed?
      :diagnosis_not_complete

    # at least one match done:
    elsif matches_status.include?(:done)
      :done
    elsif matches_status.include?(:done_no_help)
      :done_no_help
    elsif matches_status.include?(:done_not_reachable)
      :done_not_reachable

    # at least one match not closed
    elsif matches_status.include?(:taking_care)
      :taking_care
    elsif matches_status.include?(:quo)
      :quo

    # all matches rejected
    else
      :not_for_me
    end
  end

  def touch_after_badges_update(_badge)
    touch if persisted?
  end
end
