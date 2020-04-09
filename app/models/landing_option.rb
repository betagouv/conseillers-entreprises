# == Schema Information
#
# Table name: landing_options
#
#  id                           :bigint(8)        not null, primary key
#  content                      :jsonb
#  description                  :text
#  landing_sort_order           :integer
#  preselected_institution_slug :string
#  preselected_subject_slug     :string
#  slug                         :string           not null
#  title                        :string
#  landing_id                   :bigint(8)
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

  ## JSON Accessors
  #
  CONTENT_KEYS = %i[form_title form_description]
  store_accessor :content, CONTENT_KEYS
end
