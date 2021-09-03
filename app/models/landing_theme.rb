# == Schema Information
#
# Table name: landing_themes
#
#  id               :bigint(8)        not null, primary key
#  description      :text
#  logos            :string
#  main_logo        :string
#  meta_description :string
#  meta_title       :string
#  page_title       :string
#  slug             :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_landing_themes_on_slug  (slug) UNIQUE
#
class LandingTheme < ApplicationRecord
  ## Associations
  #
  has_many :landing_joint_themes, -> { order(:position) }, inverse_of: :landing_theme, dependent: :destroy
  has_many :landings, through: :landing_joint_themes, inverse_of: :landing_themes
  has_many :landing_subjects, inverse_of: :landing_theme, dependent: :destroy
  has_many :solicitations, through: :landing_subjects, inverse_of: :landing_theme

  accepts_nested_attributes_for :landing_subjects, allow_destroy: true

  before_validation :compute_slug

  ## Validation
  #
  validates :slug, presence: true, uniqueness: true

  def to_s
    title
  end

  def to_param
    slug
  end

  private

  def compute_slug
    if title.present? && slug.blank?
      self.slug = title.dasherize.parameterize
    end
  end
end
