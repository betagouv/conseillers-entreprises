# == Schema Information
#
# Table name: antennes
#
#  id             :bigint(8)        not null, primary key
#  deleted_at     :datetime
#  name           :string
#  territorial_level :enum             default("local"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  institution_id :bigint(8)        not null
#
# Indexes
#
#  index_antennes_on_deleted_at               (deleted_at)
#  index_antennes_on_institution_id           (institution_id)
#  index_antennes_on_name_and_institution_id  (name,institution_id) UNIQUE
#  index_antennes_on_territorial_level        (territorial_level)
#  index_antennes_on_updated_at               (updated_at)
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
  has_and_belongs_to_many :communes, inverse_of: :antennes
  include ManyCommunes
  include InvolvementConcern

  belongs_to :institution, inverse_of: :antennes

  has_many :experts, -> { not_deleted }, inverse_of: :antenne
  has_many :advisors, -> { not_deleted }, class_name: 'User', inverse_of: :antenne
  # /!\ Attention, méthode à revoir, un manager peut être hors antenne !
  has_many :managers, -> { role_antenne_manager }, class_name: 'User', inverse_of: :antenne
  has_many :match_filters, dependent: :destroy, inverse_of: :antenne
  accepts_nested_attributes_for :match_filters, allow_destroy: true

  has_many :quarterly_reports, dependent: :destroy, inverse_of: :antenne
  has_many :matches_reports, -> { category_matches }, class_name: 'QuarterlyReport', dependent: :destroy, inverse_of: :antenne
  has_many :stats_reports, -> { category_stats }, class_name: 'QuarterlyReport', dependent: :destroy, inverse_of: :antenne

  ## Hooks and Validations
  #
  auto_strip_attributes :name
  validates :name, presence: true, uniqueness: { scope: :institution_id }
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

  ##
  #
  scope :without_communes, -> { left_outer_joins(:communes).where(communes: { id: nil }) }

  scope :without_managers, -> { left_outer_joins(:managers).where(managers: { id: nil }) }

  scope :by_antenne_and_institution_names, -> (antennes_and_institutions_names) do
    tuples_array = antennes_and_institutions_names
    # AFAICT, expanding the tuples_array as a single `IN (?)` parameter is unsupported in ActiveRecord
    # Instead, build as many `IN ((?),(?),…)` as needed, and splat the array.
    joins(:institution)
      .where("(antennes.name, institutions.name) IN (#{(['(?)'] * tuples_array.size).join(', ')})", *tuples_array)
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

  def user_support_email
    if support_user.present?
      "#{support_user.full_name} - #{I18n.t('app_name')} <#{support_user.email}>"
    else
      "#{I18n.t('app_name')} <#{ENV['APPLICATION_EMAIL']}>"
    end
  end

  # Perimetre territorial
  #
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
    same_region_antennes = institution.antennes_in_region(region_ids)
    same_region_antennes.select do |a|
      !a.regional? && Utilities::Arrays.included_in?(a.commune_ids, commune_ids)
    end
  end

  ## Périmètre d'exercice :
  # tous les besoins auxquels une antenne peut avoir accès suivant son échelon territorial
  #
  def perimeter_received_needs
    if self.national?
      self.institution.received_needs
    elsif self.regional?
      Need.diagnosis_completed.joins(experts: :antenne).scoping do
        Need.where(experts: { antenne: self })
          .or(Need.where(experts: { antenne: self.territorial_antennes }))
      end.distinct
    else
      self.received_needs
    end
  end

  def perimeter_received_matches_from_needs(needs)
    if self.national?
      self.institution.received_matches.joins(:need).where(need: needs).distinct
    elsif self.regional?
      Match.joins(:need, expert: :antenne).scoping do
        Match.where(
          need: needs,
          expert: { antenne: self }
        )
          .or(Match.where(
                need: needs,
                expert: { antenne: self.territorial_antennes }
              ))
      end.distinct
    else
      self.received_matches.joins(:need).where(need: needs).distinct
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
end
