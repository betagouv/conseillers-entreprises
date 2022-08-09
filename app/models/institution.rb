# == Schema Information
#
# Table name: institutions
#
#  id           :bigint(8)        not null, primary key
#  code_region  :integer
#  deleted_at   :datetime
#  display_logo :boolean          default(FALSE)
#  name         :string           not null
#  show_on_list :boolean          default(FALSE)
#  siren        :text
#  slug         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_institutions_on_code_region  (code_region)
#  index_institutions_on_deleted_at   (deleted_at)
#  index_institutions_on_name         (name) UNIQUE
#  index_institutions_on_slug         (slug) UNIQUE
#  index_institutions_on_updated_at   (updated_at)
#

class Institution < ApplicationRecord
  include SoftDeletable
  include WithSlug

  ## Associations
  #
  has_many :antennes, -> { not_deleted }, inverse_of: :institution
  has_many :institutions_subjects, inverse_of: :institution
  has_many :landings, inverse_of: :institution
  has_many :solicitations, inverse_of: :institution
  has_and_belongs_to_many :categories
  has_one :logo, inverse_of: :institution
  has_many :facilities, inverse_of: :opco
  has_many :institution_filters, dependent: :destroy, as: :institution_filtrable, inverse_of: :institution_filtrable

  has_one :api_key

  ## Hooks and Validations
  #
  auto_strip_attributes :name
  validates :name, presence: true, uniqueness: true

  ## Through Associations
  #
  # :institutions_subjects
  has_many :subjects, through: :institutions_subjects, inverse_of: :institutions, dependent: :destroy
  has_many :themes, through: :institutions_subjects, inverse_of: :institutions

  # :antennes
  has_many :experts, through: :antennes, inverse_of: :institution
  has_many :advisors, through: :antennes, inverse_of: :institution
  has_many :sent_diagnoses, through: :antennes, inverse_of: :advisor_institution
  has_many :sent_needs, through: :antennes, inverse_of: :advisor_institution
  has_many :sent_matches, through: :antennes, inverse_of: :advisor_institution

  has_many :received_matches, through: :antennes, inverse_of: :expert_institution
  has_many :received_needs, through: :antennes, inverse_of: :expert_institutions
  has_many :received_diagnoses, through: :antennes, inverse_of: :expert_institutions
  has_many :received_solicitations, through: :received_diagnoses, source: :solicitation, inverse_of: :diagnosis

  # Same as :advisors and :antennes, but excluding deleted items; this makes it possible to preload not_deleted items in views.
  has_many :not_deleted_antennes, -> { not_deleted }, class_name: "Antenne", inverse_of: :institution

  accepts_nested_attributes_for :institutions_subjects, :allow_destroy => true

  ## Scopes
  #
  scope :ordered_logos, -> { not_deleted.joins(:logo).where(display_logo: true).order(:name) }
  scope :opco, -> { active.joins(:categories).where(categories: { label: 'opco' }) }
  scope :expert_provider, -> { active.joins(:categories).where(categories: { label: 'expert_provider' }) }
  scope :acquisition, -> { active.joins(:categories).where(categories: { label: 'acquisition' }) }

  scope :in_region, -> (region_id) do
    left_joins(antennes: :regions)
      .left_joins(antennes: :experts)
      .where(antennes: { territories: { id: [region_id] } })
      .or(Institution.where(experts: { is_global_zone: true }))
      .distinct
  end

  scope :omnisearch, -> (query) do
    if query.present?
      not_deleted.where("institutions.name ILIKE ?", "%#{query}%")
    end
  end

  ## Institution subjects helpers
  #

  # All the subjects that can be assigned to an expert of this institution
  def available_subjects
    institutions_subjects
      .available_subjects.grouped_by_theme
  end

  ##
  #
  def antennes_in_region(region_id)
    not_deleted_antennes
      .left_joins(:regions, :experts)
      .where(antennes: { territories: { id: [region_id] } })
      .or(self.antennes.where(experts: { is_global_zone: true }))
      .order(:name)
      .distinct
  end

  def advisors_in_region(region_id)
    advisors
      .left_joins(:regions, :experts)
      .where(antennes: { territories: { id: [region_id] } })
      .or(self.antennes.where(experts: { is_global_zone: true }))
      .distinct
  end

  def to_param
    slug
  end

  def to_s
    name
  end

  def slug_field
    name
  end

  def retrieve_antennes(region_id)
    retrieved_antennes = if region_id.present?
      antennes_in_region(region_id)
    else
      antennes
    end
    retrieved_antennes
      .not_deleted
      .order(:name)
      .preload(:communes)
  end

  def self.retrieve_institutions(region_id)
    institutions = not_deleted
      .order(:slug)
      .preload([institutions_subjects: :theme], :not_deleted_antennes, :advisors)

    institutions = institutions.in_region(region_id) if region_id.present?
    institutions
  end

  ## Soft deletion
  #
  def soft_delete
    self.transaction do
      antennes.each do |antenne|
        antenne.experts.each { |expert| expert.soft_delete }
        antenne.advisors.each { |advisor| advisor.soft_delete }
        antenne.soft_delete
      end
      update_columns(deleted_at: Time.zone.now)
    end
  end
end
