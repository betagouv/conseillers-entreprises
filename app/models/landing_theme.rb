# == Schema Information
#
# Table name: landing_themes
#
#  id               :bigint(8)        not null, primary key
#  archived_at      :datetime
#  description      :text
#  meta_description :string
#  meta_title       :string
#  page_title       :string
#  slug             :string           not null
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_landing_themes_on_archived_at  (archived_at)
#  index_landing_themes_on_slug         (slug) UNIQUE
#
class LandingTheme < ApplicationRecord
  include WithSlug
  include Archivable

  ## Associations
  #
  has_many :landing_joint_themes, -> { order(:position) }, inverse_of: :landing_theme, dependent: :destroy
  has_many :landings, through: :landing_joint_themes, inverse_of: :landing_themes
  has_many :institutions, through: :landings, inverse_of: :landing_themes

  has_many :landing_subjects, inverse_of: :landing_theme, dependent: :destroy

  has_many :subjects, through: :landing_subjects, inverse_of: :landing_themes
  has_many :themes, -> { distinct }, through: :subjects, inverse_of: :landing_themes
  has_many :theme_territories, -> { distinct }, through: :subjects, inverse_of: :landing_themes, source: :territorial_zones
  has_many :solicitations, through: :landing_subjects, inverse_of: :landing_theme
  has_many :matches, through: :solicitations, inverse_of: :landing_theme

  accepts_nested_attributes_for :landing_subjects, allow_destroy: true

  validates :slug, presence: true, uniqueness: true

  def to_s
    title
  end

  def to_param
    slug
  end

  def has_specific_themes?
    themes.any?{ |t| t.cooperation? }
  end

  def has_regional_themes?
    themes.any?{ |t| t.territorial_zones.any? }
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "archived", "archived_at", "created_at", "description", "id", "id_value", "meta_description", "meta_title",
      "page_title", "slug", "title", "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["landing_joint_themes", "landings", "institutions", "landing_subjects", "subjects", "themes", "solicitations", "cooperation"]
  end
end
