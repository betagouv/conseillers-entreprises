# == Schema Information
#
# Table name: experts
#
#  id             :bigint(8)        not null, primary key
#  deleted_at     :datetime
#  email          :string
#  full_name      :string
#  is_global_zone :boolean          default(FALSE)
#  job            :string
#  phone_number   :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  antenne_id     :bigint(8)        not null
#
# Indexes
#
#  index_experts_on_antenne_id  (antenne_id)
#  index_experts_on_deleted_at  (deleted_at)
#  index_experts_on_email       (email)
#
# Foreign Keys
#
#  fk_rails_...  (antenne_id => antennes.id)
#

class Expert < ApplicationRecord
  include PersonConcern
  include InvolvementConcern
  include SoftDeletable

  ## Associations
  #
  has_and_belongs_to_many :communes, inverse_of: :direct_experts
  include ManyCommunes

  belongs_to :antenne, inverse_of: :experts

  has_and_belongs_to_many :users, -> { not_deleted }, inverse_of: :experts

  has_many :experts_subjects, dependent: :destroy, inverse_of: :expert
  has_many :received_matches, -> { sent }, class_name: 'Match', inverse_of: :expert, dependent: :nullify
  has_many :not_received_matches, -> { not_sent }, class_name: 'Match', inverse_of: :expert, dependent: :nullify
  has_many :received_quo_matches, -> { sent.status_quo.distinct }, class_name: 'Match', inverse_of: :expert, dependent: :nullify
  has_many :reminder_feedbacks, -> { where(category: :expert_reminder) }, class_name: :Feedback, dependent: :destroy, as: :feedbackable, inverse_of: :feedbackable
  has_many :reminders_registers, inverse_of: :expert

  ## Validations & callbacks
  #
  validates :email, presence: true, unless: :deleted?
  validates :full_name, presence: true
  validates_associated :experts_subjects, on: :import
  after_update :synchronize_single_member, if: :personal_skillset?

  ## “Through” Associations
  #
  # :communes
  has_many :territories, -> { distinct.bassins_emploi }, through: :communes, inverse_of: :direct_experts

  # :antenne
  has_one :institution, through: :antenne, source: :institution, inverse_of: :experts
  has_many :antenne_communes, through: :antenne, source: :communes, inverse_of: :antenne_experts
  has_many :antenne_territories, -> { distinct }, through: :antenne, source: :territories, inverse_of: :antenne_experts
  has_many :regions, -> { distinct.regions }, through: :antenne, inverse_of: :antenne_experts
  has_many :match_filters, through: :antenne, source: :match_filters, inverse_of: :experts

  # :received_matches
  has_many :received_needs, through: :received_matches, source: :need, inverse_of: :experts
  has_many :received_diagnoses, through: :received_matches, source: :diagnosis, inverse_of: :experts

  # :experts_subjects
  has_many :institutions_subjects, through: :experts_subjects, inverse_of: :experts
  has_many :subjects, through: :experts_subjects, inverse_of: :experts

  ##
  #
  accepts_nested_attributes_for :users, allow_destroy: true
  accepts_nested_attributes_for :experts_subjects, allow_destroy: true

  paginates_per 25

  ## Scopes
  #
  scope :support_experts, -> do
    joins(:subjects)
      .where({ subjects: { is_support: true } })
  end

  # Team stuff
  scope :personal_skillsets, -> do
    # Experts with only one member only represent this user’s skills.
    single_member = Expert.unscoped.joins(:users)
      .merge(User.unscoped.not_deleted)
      .group(:id)
      .having("COUNT(users.id)=1")

    joins(:users)
      .where(id: single_member)
      .where("users.email = experts.email")
  end

  scope :only_expert_of_user, -> do
    joins(:users)
      .where(users: { id: User.unscoped.single_expert })
  end

  scope :with_users, -> { joins(:users) }

  scope :without_users, -> do
    # Experts without members can’t connect to the app.
    # This is not a normal state, but can happen during referencing
    # before users are actually registered, or when a user is removed.
    where.missing(:users)
      .merge(User.unscoped.not_deleted)
  end

  scope :teams, -> do
    # Experts (with members) that are not personal_skillsets are proper teams
    where.not(id: Expert.unscoped.without_users)
      .where.not(id: Expert.unscoped.personal_skillsets)
  end

  # Activity stuff
  # Utilisé pour les mails de relance
  scope :with_active_matches, -> do
    joins(:received_matches)
      .merge(Match.archived(false).status_quo)
      .distinct
  end

  # referent avec besoin dans boite reception vieux de + de X jours
  # Utilisation d'arel pour plaire a brakeman
  scope :with_old_needs_in_inbox, -> do
    joins(:received_quo_matches)
      .merge(Match
        .where(archived_at: nil)
        .where(Match.arel_table[:created_at].lt(RemindersRegister::MATCHES_AGE[:quo]))
        .joins(:need).where(need: { archived_at: nil }))
      .distinct
  end

  # Pas besoin de distinct avec cette méthode
  scope :most_needs_quo_first, -> do
    left_outer_joins(:received_quo_matches)
      .group(:id)
      .order('COUNT(matches.id) DESC')
  end

  # Referencing
  scope :ordered_by_institution, -> do
    joins(:antenne, :institution)
      .select('experts.*', 'antennes.name', 'institutions.name')
      .order('institutions.name', 'antennes.name', :full_name)
  end

  scope :with_custom_communes, -> do
    # The naive “joins(:communes).distinct” is way more complex.
    where('EXISTS (SELECT * FROM communes_experts WHERE communes_experts.expert_id = experts.id)')
  end
  scope :without_custom_communes, -> { where.missing(:communes) }

  scope :with_global_zone, -> do
    where(is_global_zone: true)
  end

  scope :without_subjects, -> do
    where.missing(:experts_subjects)
  end

  scope :with_subjects, -> do
    left_outer_joins(:experts_subjects)
      .where.not(experts_subjects: { id: nil })
      .distinct
  end

  scope :relevant_for_skills, -> do
    not_deleted.where(id: unscoped.teams)
      .or(not_deleted.where(id: unscoped.only_expert_of_user))
      .or(not_deleted.where(id: unscoped.with_subjects))
  end

  scope :omnisearch, -> (query) do
    joins(antenne: :institution)
      .where('experts.full_name ILIKE ?', "%#{query}%")
      .or(Expert.joins(antenne: :institution).where('antennes.name ILIKE ?', "%#{query}%"))
      .or(Expert.joins(antenne: :institution).where('institutions.name ILIKE ?', "%#{query}%"))
  end

  scope :many_pending_needs, -> { joins(:reminders_registers).where(reminders_registers: RemindersRegister.current_remainder_category.many_pending_needs_basket) }
  scope :medium_pending_needs, -> { joins(:reminders_registers).where(reminders_registers: RemindersRegister.current_remainder_category.medium_pending_needs_basket) }
  scope :one_pending_need, -> { joins(:reminders_registers).where(reminders_registers: RemindersRegister.current_remainder_category.one_pending_need_basket) }
  scope :inputs, -> { joins(:reminders_registers).where(reminders_registers: RemindersRegister.current_input_category) }
  scope :outputs, -> { joins(:reminders_registers).where(reminders_registers: RemindersRegister.current_output_category) }

  def last_reminder_register
    reminders_registers.order(:created_at).last
  end

  ## Team stuff
  def personal_skillset?
    users.size == 1 &&
      users.first.email.casecmp(self.email)&.zero?
  end

  def without_users?
    users.empty?
  end

  def team?
    !without_users? && !personal_skillset?
  end

  ## Referencing
  def custom_communes?
    communes.any?
  end

  def without_subjects?
    experts_subjects.empty?
  end

  def first_notification_help_email
    return unless received_matches.count == 1
    ExpertMailer.first_notification_help(self).deliver_later
  end

  ## Soft deletion
  #
  def full_name
    deleted? ? I18n.t('deleted_account.full_name') : self[:full_name]
  end

  def soft_delete
    self.transaction do
      if personal_skillset?
        users.each { |u| u.update_columns(SoftDeletable.persons_attributes) }
      end
      update_columns(SoftDeletable.persons_attributes)
    end
  end

  def deep_soft_delete
    self.transaction do
      users.each { |user| user.soft_delete }
      update_columns(SoftDeletable.persons_attributes)
    end
  end

  ## Updates
  #
  def synchronize_single_member
    users.first.update_columns(self.user_personal_skillsets_shared_attributes)
  end
end
