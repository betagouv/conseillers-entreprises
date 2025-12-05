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
  include WithTerritorialZones

  ## Associations
  #
  has_and_belongs_to_many :communes, inverse_of: :direct_experts

  belongs_to :antenne, inverse_of: :experts

  has_and_belongs_to_many :users, -> { not_deleted }, inverse_of: :experts

  has_many :experts_subjects, dependent: :destroy, inverse_of: :expert
  has_many :received_matches, -> { sent }, class_name: 'Match', inverse_of: :expert, dependent: :nullify
  has_many :not_received_matches, -> { not_sent }, class_name: 'Match', inverse_of: :expert, dependent: :nullify
  has_many :received_quo_matches, -> { sent.status_quo.distinct }, class_name: 'Match', inverse_of: :expert, dependent: :nullify
  has_many :reminder_feedbacks, -> { where(category: :expert_reminder) }, class_name: :Feedback, dependent: :destroy, as: :feedbackable, inverse_of: :feedbackable
  has_many :reminders_registers, inverse_of: :expert
  has_many :match_filters, as: :filtrable_element, dependent: :destroy, inverse_of: :filtrable_element
  has_many :territorial_zones, as: :zoneable, dependent: :destroy, inverse_of: :zoneable

  ## Validations & callbacks
  #
  validates :email, presence: true, unless: :deleted?
  validates :full_name, presence: true
  validates_associated :experts_subjects, on: :import

  ## “Through” Associations
  #

  # :antenne
  has_one :institution, through: :antenne, source: :institution, inverse_of: :experts
  has_many :antenne_communes, through: :antenne, source: :communes, inverse_of: :antenne_experts
  # TODO a supprimer
  # has_many :antenne_territories, -> { distinct }, through: :antenne, source: :territories, inverse_of: :antenne_experts
  # has_many :antenne_regions, -> { distinct.regions }, through: :antenne, source: :regions, inverse_of: :antenne_experts
  has_many :antenne_match_filters, through: :antenne, source: :match_filters # , inverse_of: :experts
  has_many :institution_match_filters, through: :institution, source: :match_filters # , source_type: :Institution

  # :received_matches
  has_many :received_needs, through: :received_matches, source: :need, inverse_of: :experts
  has_many :received_diagnoses, through: :received_matches, source: :diagnosis, inverse_of: :experts

  # :experts_subjects
  has_many :institutions_subjects, through: :experts_subjects, source: :institution_subject, inverse_of: :experts
  has_many :subjects, through: :experts_subjects, source: :subject, inverse_of: :experts
  has_many :themes, through: :experts_subjects, source: :theme, inverse_of: :experts

  # :users
  has_many :feedbacks, through: :users, source: :feedbacks, inverse_of: :experts

  # :shared_satisfaction
  has_many :shared_satisfactions, inverse_of: :expert
  has_many :shared_company_satisfactions, -> { distinct }, through: :shared_satisfactions, source: :company_satisfaction

  ##
  #
  accepts_nested_attributes_for :users, allow_destroy: true
  accepts_nested_attributes_for :experts_subjects, allow_destroy: true
  accepts_nested_attributes_for :match_filters, allow_destroy: true

  paginates_per 25

  ## Scopes
  #
  scope :support_experts, -> do
    joins(:subjects)
      .where({ subjects: { is_support: true } })
  end

  # Team stuff
  scope :with_one_user, -> do
    joins(:users)
      .group(:id)
      .having("COUNT(users.id)=1")
  end

  scope :with_users, -> { joins(:users) }

  # On s'appuie sur table de jointure pour éviter les faux positifs
  scope :without_users, -> do
    # Experts without members can’t connect to the app.
    # This is not a normal state, but can happen during referencing
    # before users are actually registered, or when a user is removed.
    joins("LEFT JOIN experts_users ON experts.id = experts_users.expert_id")
      .where(experts_users: { user_id: nil })
  end

  scope :active_without_users, -> do
    active.without_users
  end

  # Activity stuff
  # Utilisé pour les mails de relance
  scope :with_active_matches, -> do
    joins(:received_matches)
      .merge(Match.archived(false).status_quo)
      .distinct
  end

  # Pas besoin de distinct avec cette méthode
  scope :most_needs_quo_first, -> do
    left_outer_joins(:received_quo_matches)
      .group(:id)
      .order('COUNT(matches.id) DESC')
  end

  # Expert ayant plus de 5 besoins en cours avec date de prise en charge > 1 mois
  scope :with_taking_care_stock, -> do
    taking_care_matches = Match.sent
      .status_taking_care
      .where(taken_care_of_at: ..1.month.ago.beginning_of_day)
    Expert.joins(:received_matches)
      .merge(taking_care_matches)
      .group(:id)
      .having("COUNT(matches.id)>5")
  end

  # Referencing
  scope :ordered_by_institution, -> do
    joins(:antenne, :institution)
      .select('experts.*', 'antennes.name', 'institutions.name')
      .order('institutions.name', 'antennes.name', :full_name)
  end

  # Geographical methods
  #
  scope :with_territorial_zones, -> { not_deleted.joins(:territorial_zones) }
  scope :without_territorial_zones, -> { not_deleted.where.not(id: with_territorial_zones.ids) }

  # TODO: remove this method when communes_experts is removed
  scope :with_custom_communes_old, -> do
    # The naive “joins(:communes).distinct” is way more complex.
    not_deleted.where('EXISTS (SELECT * FROM communes_experts WHERE communes_experts.expert_id = experts.id)')
  end

  scope :with_global_zone, -> do
    where(is_global_zone: true)
  end

  scope :with_national_perimeter, -> do
    joins(:antenne).with_global_zone.or(joins(:antenne).merge(Antenne.territorial_level_national))
  end

  # Override du scope by_region du concern pour gérer les experts avec et sans territoires specifiques
  scope :by_region, -> (region_code) do
    return all if region_code.blank?
    without_territorial_zones = self.without_territorial_zones.joins(:antenne).merge(Antenne.by_region(region_code)).ids
    with_territorial_zones = self.with_territorial_zones.where(territorial_zones: { regions_codes: [region_code] }).ids
    where(id: without_territorial_zones + with_territorial_zones)
  end

  scope :by_theme, -> (theme_id) do
    return all if theme_id.blank?
    joins(:themes).where(themes: theme_id)
  end

  scope :by_subject, -> (subject_id) do
    return all if subject_id.blank?
    joins(:subjects).where(subjects: subject_id)
  end

  # param peut être un code de région ou une clé correspondant à un scope ("with_national_perimeter" par ex)
  scope :by_possible_region, -> (param) {
    begin
      by_region(param)
    rescue ActiveRecord::RecordNotFound => _e
      self.send(param) if [I18n.t('helpers.expert.national_perimeter.value')].include?(param)
    end
  }

  scope :without_subjects, -> do
    where.missing(:experts_subjects)
  end

  scope :active_without_subjects, -> do
    active.without_subjects
  end

  scope :active_with_matches_and_without_subjects, -> do
    active
      .without_subjects
      .left_joins(:received_matches)
      .where.not(received_matches: { id: nil })
  end

  scope :with_subjects, -> do
    left_outer_joins(:experts_subjects)
      .where.not(experts_subjects: { id: nil })
      .distinct
  end

  scope :omnisearch, -> (query) do
    joins(:users, antenne: :institution,)
      .where('experts.full_name ILIKE ?', "%#{query}%")
      .or(Expert.joins(:users, antenne: :institution).where('antennes.name ILIKE ?', "%#{query}%"))
      .or(Expert.joins(:users, antenne: :institution).where('institutions.name ILIKE ?', "%#{query}%"))
      .or(Expert.joins(:users, antenne: :institution).where(users: { id: User.omnisearch(query).select(:id) }))
  end

  scope :by_full_name, -> (query) do
    joins(:users, :received_quo_matches)
      .where('experts.full_name ILIKE ?', "%#{query}%")
      .or(Expert.joins(:users, :received_quo_matches).merge(User.by_name(query)))
  end

  scope :regions_eq, -> (region_code) {
    by_region(region_code)
  }

  scope :many_pending_needs, -> { joins(:reminders_registers).where(reminders_registers: RemindersRegister.current_remainder_category.many_pending_needs_basket) }
  scope :medium_pending_needs, -> { joins(:reminders_registers).where(reminders_registers: RemindersRegister.current_remainder_category.medium_pending_needs_basket) }
  scope :one_pending_need, -> { joins(:reminders_registers).where(reminders_registers: RemindersRegister.current_remainder_category.one_pending_need_basket) }
  scope :in_reminders_registers, -> { joins(:reminders_registers).where(reminders_registers: RemindersRegister.current_remainder_category).distinct }
  scope :inputs, -> { joins(:reminders_registers).where(reminders_registers: RemindersRegister.current_input_category) }
  scope :outputs, -> { joins(:reminders_registers).where(reminders_registers: RemindersRegister.current_output_category) }
  scope :expired_needs, -> { joins(:reminders_registers).where(reminders_registers: RemindersRegister.current_expired_need_category) }

  scope :without_shared_satisfaction, -> { where.missing(:shared_satisfactions) }

  scope :in_commune, -> (insee_code) do
    return none if insee_code.blank?

    commune = ::DecoupageAdministratif::Commune.find(insee_code)
    return none if commune.nil?

    # Experts with specific territorial zones that cover this commune
    experts_with_zones_ids = left_joins(:territorial_zones)
      .where(territorial_zones: { zone_type: :commune, code: insee_code })
      .or(left_joins(:territorial_zones).where(territorial_zones: { zone_type: :epci, code: commune.epci&.code }))
      .or(left_joins(:territorial_zones).where(territorial_zones: { zone_type: :departement, code: commune.departement.code }))
      .or(left_joins(:territorial_zones).where(territorial_zones: { zone_type: :region, code: commune.region_code })).ids

    # Get all experts that have specific territorial zones (to exclude them from antenne-based search)
    experts_with_any_zones_ids = with_territorial_zones.ids

    # Experts without specific zones, relying on their antenne's coverage
    experts_without_zones_ids = where.not(id: experts_with_any_zones_ids)
      .left_joins(antenne: :territorial_zones)
      .where(territorial_zones: { zone_type: :commune, code: insee_code })
      .or(where.not(id: experts_with_any_zones_ids).left_joins(antenne: :territorial_zones).where(territorial_zones: { zone_type: :epci, code: commune.epci&.code }))
      .or(where.not(id: experts_with_any_zones_ids).left_joins(antenne: :territorial_zones).where(territorial_zones: { zone_type: :departement, code: commune.departement.code }))
      .or(where.not(id: experts_with_any_zones_ids).left_joins(antenne: :territorial_zones).where(territorial_zones: { zone_type: :region, code: commune.region_code }))
      .or(where.not(id: experts_with_any_zones_ids).left_joins(antenne: :territorial_zones).where(is_global_zone: true)).ids

    where(id: experts_with_zones_ids).or(where(id: experts_without_zones_ids))
  end

  scope :by_insee_code, -> (insee_code) {
    territories = DecoupageAdministratif::Search.new.find_territories_by_commune_insee_code(insee_code)
    zone_types = [:epci, :departement, :region]
    experts_ids = []
    zone_types.each do |zone_type|
      next if territories[zone_type].nil?
      experts_ids << Expert.joins(:territorial_zones).where(territorial_zones: { code: territories[zone_type].code, zone_type: zone_type }, is_global_zone: false).distinct.ids
      experts_ids << Expert.joins(antenne: :territorial_zones).where(territorial_zones: { code: territories[zone_type].code, zone_type: zone_type }).distinct.ids
    end

    # Include global experts
    experts_ids << Expert.where(is_global_zone: true).ids

    where(id: experts_ids.uniq.flatten)
  }

  def self.apply_filters(params)
    klass = self
    klass = klass.omnisearch(params[:omnisearch]) if params[:omnisearch].present?
    klass = klass.by_possible_region(params[:by_region]) if params[:by_region].present?
    klass = klass.by_full_name(params[:by_full_name]) if params[:by_full_name].present?
    klass = klass.joins(:antenne).where(antennes: { institution_id: params[:institution_id] }) if params[:institution_id].present?
    klass.all
  end

  def last_reminder_register
    reminders_registers.order(:created_at).last
  end

  def currently_in_reminders?
    last_reminder_register&.run_number == RemindersRegister.last_run_number
  end

  def input_register
    reminders_registers.current_input_category.first
  end

  def output_register
    reminders_registers.current_output_category.first
  end

  def expired_need_register
    reminders_registers.current_expired_need_category.first
  end

  def without_users?
    users.empty?
  end

  def with_one_user?
    users.size == 1
  end

  def with_identical_user?
    users.size == 1 && users.first.email == email && users.first.full_name == full_name
  end

  def support_user
    antenne.support_user
  end

  # Utilisé pour la réattribution des matches d'un expert
  def transfer_in_progress_matches(expert)
    ActiveRecord::Base.transaction do
      received_matches.in_progress.each do |match|
        match.update(expert: expert)
      end
    end
  end

  ## Referencing
  def custom_territories?
    territorial_zones.any?
  end

  def without_subjects?
    experts_subjects.empty?
  end

  def first_notification_help_email
    return unless received_matches.one?
    ExpertMailer.with(expert: self).first_notification_help.deliver_later
  end

  ## Soft deletion
  #
  def full_name
    deleted? ? I18n.t('deleted_account.full_name') : self[:full_name]
  end

  def soft_delete
    self.transaction do
      update_columns(SoftDeletable.persons_attributes)
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "antenne_id", "created_at", "deleted_at", "email", "full_name", "id", "id_value", "is_global_zone", "job",
      "phone_number", "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "antenne",
      "experts_subjects", "institution", "institutions_subjects", "match_filters", "not_received_matches",
      "received_diagnoses", "received_matches", "received_needs", "received_quo_matches", "reminder_feedbacks",
      "reminders_registers", "subjects", "territories", "themes", "users"
    ]
  end

  def self.ransackable_scopes(auth_object = nil)
    ["regions_eq"]
  end
end
