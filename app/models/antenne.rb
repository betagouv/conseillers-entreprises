# == Schema Information
#
# Table name: antennes
#
#  id                :bigint(8)        not null, primary key
#  deleted_at        :datetime
#  name              :string
#  territorial_level :enum             default("local"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  institution_id    :bigint(8)        not null
#  parent_antenne_id :bigint(8)
#
# Indexes
#
#  index_antennes_on_deleted_at                              (deleted_at)
#  index_antennes_on_institution_id                          (institution_id)
#  index_antennes_on_name_and_deleted_at_and_institution_id  (name,deleted_at,institution_id)
#  index_antennes_on_parent_antenne_id                       (parent_antenne_id)
#  index_antennes_on_territorial_level                       (territorial_level)
#  index_antennes_on_updated_at                              (updated_at)
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#

class Antenne < ApplicationRecord
  include SoftDeletable
  include ManyCommunes
  include InvolvementConcern
  include TerritoryNeedsStatus

  enum :territorial_level, {
    local: 'local',
    regional: 'regional',
    national: 'national'
  }, prefix: true

  TERRITORIAL_ORDER = {
    national: 0,
    regional: 1,
    local: 2
  }

  ## Associations
  #
  has_and_belongs_to_many :communes, inverse_of: :antennes, after_add: [:update_referencement_coverages, :update_antenne_hierarchy], after_remove: [:update_referencement_coverages, :update_antenne_hierarchy]

  belongs_to :institution, inverse_of: :antennes

  has_many :experts, -> { not_deleted }, inverse_of: :antenne, after_add: :update_referencement_coverages, after_remove: :update_referencement_coverages
  has_many :experts_including_deleted, class_name: 'Expert', inverse_of: :antenne
  has_many :advisors, -> { not_deleted }, class_name: 'User', inverse_of: :antenne
  has_many :match_filters, as: :filtrable_element, dependent: :destroy, inverse_of: :filtrable_element
  accepts_nested_attributes_for :match_filters, allow_destroy: true

  has_many :quarterly_reports, dependent: :destroy, inverse_of: :antenne
  has_many :matches_reports, -> { category_matches }, class_name: 'QuarterlyReport', dependent: :destroy, inverse_of: :antenne
  has_many :stats_reports, -> { category_stats }, class_name: 'QuarterlyReport', dependent: :destroy, inverse_of: :antenne

  # rights / roles
  has_many :user_rights, as: :rightable_element, dependent: :destroy, inverse_of: :rightable_element
  has_many :user_rights_managers, ->{ category_manager }, as: :rightable_element, class_name: 'UserRight', inverse_of: :rightable_element
  has_many :managers, -> { distinct }, through: :user_rights_managers, source: :user, inverse_of: :managed_antennes

  has_many :referencement_coverages, dependent: :destroy, inverse_of: :antenne

  belongs_to :parent_antenne, class_name: 'Antenne', inverse_of: :child_antennes, optional: true
  has_many :child_antennes, class_name: 'Antenne', inverse_of: :parent_antenne, foreign_key: 'parent_antenne_id'

  ## Hooks and Validations
  #
  auto_strip_attributes :name
  validates :name, presence: true
  validate :uniqueness_name
  validates_associated :managers, on: :import, if: -> { managers.any? }

  ## “Through” Associations
  #
  # :communes
  has_many :territories, -> { distinct.bassins_emploi }, through: :communes, inverse_of: :antennes
  has_many :regions, -> { distinct.regions }, through: :communes, inverse_of: :antennes

  # :advisors
  has_many :sent_diagnoses, through: :advisors, inverse_of: :advisor_antenne
  has_many :sent_needs, through: :advisors, inverse_of: :advisor_antenne
  has_many :sent_matches, through: :advisors, inverse_of: :advisor_antenne

  # :experts
  has_many :received_matches, through: :experts, inverse_of: :expert_antenne
  has_many :received_needs, through: :experts, inverse_of: :expert_antennes
  has_many :received_diagnoses, through: :experts, inverse_of: :expert_antennes
  has_many :received_solicitations, through: :received_diagnoses, source: :solicitation, inverse_of: :diagnosis

  has_many :received_matches_including_from_deleted_experts, through: :experts_including_deleted, source: :received_matches, inverse_of: :expert_antenne
  has_many :received_needs_including_from_deleted_experts, through: :experts_including_deleted, source: :received_needs, inverse_of: :expert_antennes
  has_many :received_diagnoses_including_from_deleted_experts, through: :experts_including_deleted, source: :received_diagnoses, inverse_of: :expert_antennes
  has_many :received_solicitations_including_from_deleted_experts, through: :received_diagnoses_including_from_deleted_experts, source: :solicitation, inverse_of: :diagnosis

  has_many :experts_subjects, through: :experts

  # :institution
  has_many :themes, through: :institution, inverse_of: :antennes

  ## Callbacks
  #
  after_create :check_territorial_level
  after_update :update_antenne_hierarchy, if: :saved_change_to_territorial_level?

  ##
  #
  scope :without_communes, -> { where.missing(:communes) }

  scope :without_managers, -> { where.missing(:managers) }

  scope :by_antenne_and_institution_names, -> (antennes_and_institutions_names) do
    tuples_array = antennes_and_institutions_names
    # AFAICT, expanding the tuples_array as a single `IN (?)` parameter is unsupported in ActiveRecord
    # Instead, build as many `IN ((?),(?),…)` as needed, and splat the array.
    joins(:institution)
      .where("(antennes.name, institutions.name) IN (#{(['(?)'] * tuples_array.size).join(', ')})", *tuples_array)
  end

  scope :omnisearch, -> (query) do
    if query.present?
      not_deleted.where("antennes.name ILIKE ?", "%#{query}%")
    end
  end

  scope :with_experts_subjects, -> { where.associated(:experts_subjects).distinct }

  scope :by_region, -> (region_id) do
    joins(:regions).where(regions: { id: region_id })
  end

  scope :by_subject, -> (subject_id) do
    joins(experts: :subjects).where(subjects: { id: subject_id })
  end

  scope :by_theme, -> (theme_id) do
    joins(institution: :themes).where(themes: { id: theme_id })
  end

  scope :by_higher_territorial_level, -> {
    self.sort { |a, b| TERRITORIAL_ORDER[a.territorial_level.to_sym] <=> TERRITORIAL_ORDER[b.territorial_level.to_sym] }
  }

  ##
  #
  def self.apply_filters(params)
    klass = self
    klass = klass.by_region(params[:region]) if params[:region].present?
    klass = klass.by_subject(params[:subject]) if params[:subject].present?
    klass = klass.by_theme(params[:theme]) if params[:theme].present?
    klass.all
  end

  def to_s
    name
  end

  def support_user
    if !national? && regions.count == 1
      User.find(Antenne.find(id).regions.first.support_contact_id)
    else
      UserRight.category_national_referent.first&.user
    end
  end

  def support_user_name
    [support_user&.full_name, I18n.t('app_name')].compact.join(" - ")
  end

  def support_user_email_with_name
    email = support_user.present? ? support_user.email : ENV['APPLICATION_EMAIL']
    "#{support_user_name} <#{email}>"
  end

  def uniqueness_name
    # Utilise le .reject et .present? car a la mise à jour l’antenne est persisté mais pas à la création
    if Antenne.not_deleted.where(name: name, institution: institution).reject { |a| a == self }.present?
      self.errors.add(:name, I18n.t('errors.messages.exclusion'))
    end
  end

  # Perimetre territorial
  #
  # en after_create, sinon les "regions" (en `through`) ne sont pas accessibles
  def check_territorial_level
    if (regions.size == 1) && Utilities::Arrays.same?(regions.first.commune_ids, commune_ids)
      update(territorial_level: :regional)
    end
  end

  def local?
    territorial_level_local?
  end

  def regional?
    territorial_level_regional?
  end

  def national?
    territorial_level_national?
  end

  # A surveiller : une antenne peut-elle avoir plusieurs antennes regionales ?
  def regional_antenne
    return unless self.local?
    self.parent_antenne
  end

  def territorial_antennes
    if self.local?
      []
    elsif self.national?
      Antenne.not_deleted.where(institution: self.institution).where.not(id: self.id)
    else
      self.child_antennes
    end
  end

  ## Périmètre d'exercice :
  # tous les besoins auxquels une antenne peut avoir accès suivant son échelon territorial
  #
  def perimeter_received_needs
    Rails.cache.fetch(['perimeter_received_needs', id, territorial_level], expires_in: 1.hour) do
      if self.national?
        self.institution.perimeter_received_needs
      elsif self.regional?
        antenne_ids = self.territorial_antennes.pluck(:id) << self.id
        Need
          .diagnosis_completed
          .joins(experts: :antenne)
          .where(experts: { antenne_id: antenne_ids })
          .distinct
      else
        self.received_needs_including_from_deleted_experts
      end
    end
  end

  def perimeter_received_matches
    Rails.cache.fetch(['perimeter_received_matches', id, territorial_level], expires_in: 1.hour) do
      if self.national?
        self.institution.perimeter_received_matches
      elsif self.regional?
        antenne_ids = self.territorial_antennes.pluck(:id) << self.id
        Match
          .joins(expert: :antenne)
          .sent
          .where(expert: { antenne_id: antenne_ids })
          .distinct
      else
        self.received_matches_including_from_deleted_experts
      end
    end
  end

  def perimeter_received_matches_from_needs(needs)
    Rails.cache.fetch(['perimeter_received_matches_from_needs', id, needs.map(&:id)], expires_in: 1.hour) do
      if self.national?
        self.institution.perimeter_received_matches_from_needs(needs)
      elsif self.regional?
        antenne_ids = self.territorial_antennes.pluck(:id) << self.id
        Match.joins(:need, expert: :antenne)
          .where(need: needs, expert: { antenne_id: antenne_ids })
          .distinct
      else
        self.received_matches_including_from_deleted_experts.joins(:need).where(need: needs).distinct
      end
    end
  end

  # Flexible find
  #
  def self.flexible_find_or_initialize(institution, name)
    return nil unless institution.present? && name.present?
    antenne = institution.antennes.find_by('lower(name) = ?', name.squish.downcase)
    antenne ||= Antenne.new(institution: institution, name: name.squish)
  end

  def self.flexible_find(institution, name)
    return nil unless institution.present? && name.present?
    institution.antennes.find_by('lower(name) = ?', name.squish.downcase)
  end

  ## Soft deletion
  #
  def soft_delete
    return self.errors.add(:base) if experts.not_deleted.present? || advisors.not_deleted.present?
    update_columns(deleted_at: Time.zone.now)
  end

  def update_antenne_hierarchy(*args)
    scheduled = Sidekiq::ScheduledSet.new

    scheduled.each do |job|
      if job['class'] == UpdateAntenneHierarchyJob.to_s && job['args'].first == self.id
        job.delete
      end
    end
    UpdateAntenneHierarchyJob.perform_in(20.seconds, self.id)
  end

  ## referencement coverage
  #

  # Updated when changed : add/remove communes - add/remove experts - add/remove expert communes - add/remove expert subject
  def update_referencement_coverages(*args)
    scheduled = Sidekiq::ScheduledSet.new

    scheduled.each do |job|
      if job['class'] == AntenneCoverage::DeduplicatedJob.to_s && job['args'].first == self.id
        job.delete
      end
    end
    AntenneCoverage::DeduplicatedJob.perform_in(30.seconds, self.id)
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "deleted_at", "id", "id_value", "institution_id", "name", "territorial_level", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "advisors", "communes", "experts", "experts_including_deleted", "institution", "managers", "match_filters",
      "matches_reports", "quarterly_reports", "received_diagnoses", "received_diagnoses_including_from_deleted_experts",
      "received_matches", "received_matches_including_from_deleted_experts", "received_needs",
      "received_needs_including_from_deleted_experts", "received_solicitations",
      "received_solicitations_including_from_deleted_experts", "referencement_coverages", "regions", "sent_diagnoses",
      "sent_matches", "sent_needs", "stats_reports", "territories", "themes", "user_rights", "user_rights_manager"
    ]
  end
end
