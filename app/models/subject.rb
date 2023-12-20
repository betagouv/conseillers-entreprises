# == Schema Information
#
# Table name: subjects
#
#  id                   :integer          not null, primary key
#  archived_at          :datetime
#  interview_sort_order :integer
#  is_support           :boolean          default(FALSE)
#  label                :string           not null
#  slug                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  theme_id             :bigint(8)        not null
#
# Indexes
#
#  index_subjects_on_archived_at           (archived_at)
#  index_subjects_on_interview_sort_order  (interview_sort_order)
#  index_subjects_on_label                 (label) UNIQUE
#  index_subjects_on_slug                  (slug) UNIQUE
#  index_subjects_on_theme_id              (theme_id)
#
# Foreign Keys
#
#  fk_rails_...  (theme_id => themes.id)
#

class Subject < ApplicationRecord
  ##
  #
  include Archivable

  ## Associations
  #
  belongs_to :theme, inverse_of: :subjects

  has_many :needs, inverse_of: :subject
  has_many :landing_subjects, inverse_of: :subject
  has_many :institutions_subjects, inverse_of: :subject
  has_many :additional_subject_questions, inverse_of: :subject
  has_and_belongs_to_many :match_filters

  ## Validations
  #
  validates :slug, presence: true
  validates :label, presence: true, uniqueness: true
  before_validation :compute_slug
  before_save :set_support

  ## Through Associations
  #
  # :needs
  has_many :diagnoses, through: :needs, inverse_of: :subjects

  # :matches
  has_many :matches, inverse_of: :subject

  # :institutions_subjects
  #
  has_many :institutions, through: :institutions_subjects, inverse_of: :subjects
  has_many :experts_subjects, through: :institutions_subjects, inverse_of: :subject
  has_many :experts, through: :institutions_subjects, inverse_of: :subjects

  ## Scopes
  #
  scope :ordered_for_interview, -> do
    left_outer_joins(:theme)
      .not_archived
      .merge(Theme.ordered_for_interview)
      .order(:interview_sort_order, :id)
  end

  scope :for_interview, -> do
    ordered_for_interview
      .archived(false)
      .where(is_support: false)
  end

  def copy_experts_from_other(other)
    self.transaction do
      self.institutions_subjects.destroy_all
      other.institutions_subjects.each do |other_institutions_subjects|
        experts_subjects_attributes =  other_institutions_subjects.experts_subjects.map{ |es| es.attributes.symbolize_keys.slice(:description, :job, :expert_id) }
        i = InstitutionSubject.new(
          description: other_institutions_subjects.description,
          institution: other_institutions_subjects.institution,
          experts_subjects_attributes: experts_subjects_attributes
        )
        self.institutions_subjects << i
      end
    end
  end

  ##
  #
  def to_s
    label
  end

  def full_label
    "#{theme.label} : #{label}"
  end

  ##
  #
  def self.support_subject
    find_by(is_support: true)
  end

  def define_as_support!
    update(is_support: true)
  end

  # Sujet avec traitement spécifique
  def self.other_need_subject
    Subject.find(59)
  end

  def compute_slug
    if theme&.label.present? && label.present?
      self.slug = [self.theme.label.parameterize.underscore, label.parameterize.underscore].join('_')
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "archived", "archived_at", "created_at", "id", "id_value", "interview_sort_order", "is_support", "label", "slug",
      "theme_id", "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["additional_subject_questions", "diagnoses", "experts", "experts_subjects", "institutions", "institutions_subjects", "landing_subjects", "match_filters", "matches", "needs", "theme"]
  end

  private

  def set_support
    if is_support
      Subject.where.not(id: id).update_all(is_support: false)
    end
  end
end
