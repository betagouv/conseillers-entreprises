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
#
# Indexes
#
#  index_antennes_on_deleted_at                              (deleted_at)
#  index_antennes_on_institution_id                          (institution_id)
#  index_antennes_on_name_and_deleted_at_and_institution_id  (name,deleted_at,institution_id)
#  index_antennes_on_territorial_level                       (territorial_level)
#  index_antennes_on_updated_at                              (updated_at)
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#

class Antenne < ApplicationRecord
  include SoftDeletable

  enum territorial_level: {
    local: 'local',
    regional: 'regional',
    national: 'national'
  }, _prefix: true

  ## Associations
  #
  has_and_belongs_to_many :communes, inverse_of: :antennes, after_add: :update_referencement_coverages, after_remove: :update_referencement_coverages
  include ManyCommunes
  include InvolvementConcern
  include TerritoryNeedsStatus

  belongs_to :institution, inverse_of: :antennes

  has_many :experts, -> { not_deleted }, inverse_of: :antenne, after_add: :update_referencement_coverages, after_remove: :update_referencement_coverages
  has_many :experts_including_deleted, class_name: 'Expert', inverse_of: :antenne
  has_many :advisors, -> { not_deleted }, class_name: 'User', inverse_of: :antenne
  has_many :match_filters, dependent: :destroy, inverse_of: :antenne
  accepts_nested_attributes_for :match_filters, allow_destroy: true

  has_many :quarterly_reports, dependent: :destroy, inverse_of: :antenne
  has_many :matches_reports, -> { category_matches }, class_name: 'QuarterlyReport', dependent: :destroy, inverse_of: :antenne
  has_many :stats_reports, -> { category_stats }, class_name: 'QuarterlyReport', dependent: :destroy, inverse_of: :antenne

  # rights / roles
  has_many :user_rights, inverse_of: :antenne, dependent: :destroy
  has_many :user_rights_manager, ->{ category_manager }, class_name: 'UserRight', inverse_of: :antenne
  has_many :managers, -> { distinct }, through: :user_rights_manager, source: :user, inverse_of: :managed_antennes

  has_many :referencement_coverages, dependent: :destroy, inverse_of: :antenne

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

  # :institution
  has_many :themes, through: :institution, inverse_of: :antennes

  ## Callbacks
  #
  after_create :check_territorial_level

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

  ##
  #
  def to_s
    name
  end

  def support_user
    return if regions.many? || regions.blank?
    User.find(Antenne.find(id).regions.first.support_contact_id)
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
    same_region_antennes = institution.antennes_in_region(region_ids)
    same_region_antennes.select do |a|
      a.regional? && Utilities::Arrays.included_in?(commune_ids, a.commune_ids)
    end&.first
  end

  def territorial_antennes
    return [] if self.local?
    Antenne.not_deleted.where(institution_id: institution_id, territorial_level: 'local')
      .left_joins(:communes, :experts)
      .where(communes: { id: commune_ids })
      .or(Antenne.not_deleted.where(institution_id: institution_id, territorial_level: 'local').where(experts: { is_global_zone: true }))
      .distinct
  end

  ## Périmètre d'exercice :
  # tous les besoins auxquels une antenne peut avoir accès suivant son échelon territorial
  #
  def perimeter_received_needs
    Rails.cache.fetch(['perimeter_received_needs', id], expires_in: 1.hour) do
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
    Rails.cache.fetch(['perimeter_received_matches', id], expires_in: 1.hour) do
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

  def deep_soft_delete
    self.transaction do
      experts.each { |e| e.deep_soft_delete }
      update_columns(deleted_at: Time.zone.now)
    end
  end

  ## referencement coverage
  #

  # Updated when changed : add/remove communes - add/remove experts - add/remove expert communes - add/remove expert subject
  def update_referencement_coverages(*args)
    AntenneCoverage::DeduplicatedJob.new(self).call
  end
end
