# == Schema Information
#
# Table name: landing_subjects
#
#  id                             :bigint(8)        not null, primary key
#  description                    :text
#  description_explanation        :text
#  display_region_logo            :boolean          default(FALSE)
#  form_description               :text
#  form_title                     :string
#  meta_description               :string
#  meta_title                     :string
#  position                       :integer
#  requires_location              :boolean          default(FALSE), not null
#  requires_requested_help_amount :boolean          default(FALSE), not null
#  requires_siret                 :boolean          default(FALSE), not null
#  slug                           :string
#  title                          :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  landing_theme_id               :bigint(8)        not null
#  subject_id                     :bigint(8)        not null
#
# Indexes
#
#  index_landing_subjects_on_landing_theme_id           (landing_theme_id)
#  index_landing_subjects_on_slug_and_landing_theme_id  (slug,landing_theme_id) UNIQUE
#  index_landing_subjects_on_subject_id                 (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (landing_theme_id => landing_themes.id)
#  fk_rails_...  (subject_id => subjects.id)
#
class LandingSubject < ApplicationRecord
  ## Associations
  #
  belongs_to :subject, inverse_of: :landing_subjects
  belongs_to :landing_theme, inverse_of: :landing_subjects
  has_many :solicitations, inverse_of: :landing_subject, dependent: :restrict_with_exception
  has_and_belongs_to_many :logos, -> { order(:name) }, inverse_of: :landing_subjects

  before_validation :compute_slug

  ## Validation
  #
  validates :slug, presence: true, uniqueness: true

  ## Scopes
  #
  scope :ordered_for_landing, -> { order(:position, :id) }

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

  def compute_slug
    if title.present? && slug.blank?
      self.slug = title.dasherize.parameterize
    end
  end
end
