# == Schema Information
#
# Table name: landing_subjects
#
#  id                             :bigint(8)        not null, primary key
#  archived_at                    :datetime
#  description                    :text
#  description_explanation        :text
#  description_prefill            :text
#  display_region_logo            :boolean          default(FALSE)
#  form_description               :text
#  form_title                     :string
#  meta_description               :string
#  meta_title                     :string
#  position                       :integer
#  requires_location              :boolean          default(FALSE), not null
#  requires_requested_help_amount :boolean          default(FALSE), not null
#  requires_siret                 :boolean          default(TRUE), not null
#  slug                           :string
#  title                          :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  landing_theme_id               :bigint(8)        not null
#  subject_id                     :bigint(8)        not null
#
# Indexes
#
#  index_landing_subjects_on_archived_at       (archived_at)
#  index_landing_subjects_on_landing_theme_id  (landing_theme_id)
#  index_landing_subjects_on_slug              (slug) UNIQUE
#  index_landing_subjects_on_subject_id        (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (landing_theme_id => landing_themes.id)
#  fk_rails_...  (subject_id => subjects.id)
#
class LandingSubject < ApplicationRecord
  include WithSlug
  include Archivable

  ## Associations
  #
  belongs_to :subject, inverse_of: :landing_subjects
  belongs_to :landing_theme, inverse_of: :landing_subjects
  has_many :institutions, through: :landing_theme, inverse_of: :landing_subjects
  has_many :landings, through: :landing_theme, inverse_of: :landing_subjects
  has_many :solicitations, inverse_of: :landing_subject, dependent: :restrict_with_exception
  has_many :additional_subject_questions, through: :subject
  has_many :institutions_subjects, through: :subject
  has_many :solicitable_institutions, -> { active }, through: :institutions_subjects, class_name: 'Institution', source: :institution
  has_many :matches, through: :solicitations, inverse_of: :landing_subject

  ## Scopes
  #
  scope :ordered_for_landing, -> { order(:position, :id) }

  before_save :autoclean_textareas

  validate :unique_required_field_if_siret

  def to_s
    slug
  end

  def to_param
    slug
  end

  REQUIRED_FIELDS_FLAGS = %i[
    requires_full_name
    requires_phone_number
    requires_email
    requires_siret
    requires_requested_help_amount
    requires_location
  ]
  REQUIRED_FIELDS_FLAGS.each do |flag|
    scope flag, -> { where(flag => true) }
    scope "not_#{flag}", -> { where(flag => false) }
  end

  def required_fields
    attributes.symbolize_keys
      .slice(*REQUIRED_FIELDS_FLAGS)
      .filter{ |_, value| value }
      .keys
      .map{ |flag| flag.to_s.delete_prefix('requires_').to_sym }
  end

  def unique_required_field_if_siret
    if (requires_siret == true) && (required_fields.length > 1)
      errors.add(:base, "ne peut être coché en même temps que d'autres champs")
      landing_theme.errors.add(:base, "ne peut être coché en même temps que d'autres champs")
    end
  end

  def solicitable_institutions_names
    return [] if solicitable_institutions.with_logo.empty?
    partenaires = solicitable_institutions.with_logo.order(:name).reject{ |i| i.opco? }.pluck(:name).uniq
    partenaires << I18n.t('attributes.opco') if solicitable_institutions.opco.any?
    partenaires
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "archived", "archived_at", "created_at", "description", "description_explanation", "description_prefill",
      "display_region_logo", "form_description", "form_title", "id", "id_value", "landing_theme_id", "meta_description",
      "meta_title", "position", "requires_location", "requires_requested_help_amount", "requires_siret", "slug",
      "subject_id", "title", "updated_at"
    ]
  end

  private

  def autoclean_textareas
    cleanable_fields = %i[description description_explanation description_prefill form_description]
    cleanable_fields.each do |attribute_name|
      self[attribute_name] = self[attribute_name].gsub('<p><br></p>','') if self[attribute_name].present?
    end
  end
end
