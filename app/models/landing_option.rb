# == Schema Information
#
# Table name: landing_options
#
#  id                             :bigint(8)        not null, primary key
#  description_explanation        :string
#  form_description               :string
#  form_title                     :string
#  landing_sort_order             :integer
#  meta_title                     :string
#  preselected_institution_slug   :string
#  preselected_subject_slug       :string
#  requires_email                 :boolean          default(FALSE), not null
#  requires_full_name             :boolean          default(FALSE), not null
#  requires_location              :boolean          default(FALSE), not null
#  requires_phone_number          :boolean          default(FALSE), not null
#  requires_requested_help_amount :boolean          default(FALSE), not null
#  requires_siret                 :boolean          default(FALSE), not null
#  slug                           :string           not null
#  landing_id                     :bigint(8)
#
# Indexes
#
#  index_landing_options_on_landing_id  (landing_id)
#  index_landing_options_on_slug        (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (landing_id => landings.id)
#

class LandingOption < ApplicationRecord
  ## Associations
  #
  belongs_to :landing, inverse_of: :landing_options, touch: true

  # rubocop:disable Rails/InverseOf
  belongs_to :preselected_institution, class_name: 'Institution', primary_key: :slug, foreign_key: :preselected_institution_slug, optional: true
  belongs_to :preselected_subject, class_name: 'Subject', primary_key: :slug, foreign_key: :preselected_subject_slug, optional: true
  # rubocop:enable Rails/InverseOf

  ## Validation
  #
  validates :slug, presence: true, uniqueness: true

  ## Scopes
  #
  scope :ordered_for_landing, -> { order(:landing_sort_order, :id) }

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
end
