# == Schema Information
#
# Table name: landings
#
#  id                              :bigint(8)        not null, primary key
#  archived_at                     :datetime
#  custom_css                      :string
#  display_partner_url             :boolean          default(FALSE)
#  display_pde_partnership_mention :boolean          default(FALSE)
#  emphasis                        :boolean          default(FALSE)
#  home_description                :text             default("")
#  iframe_category                 :integer          default("integral")
#  integration                     :integer          default("intern")
#  layout                          :integer          default("multiple_steps")
#  meta_description                :string
#  meta_title                      :string
#  partner_url                     :string
#  slug                            :string           not null
#  title                           :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  cooperation_id                  :bigint(8)
#  institution_id                  :bigint(8)
#
# Indexes
#
#  index_landings_on_archived_at     (archived_at)
#  index_landings_on_cooperation_id  (cooperation_id)
#  index_landings_on_institution_id  (institution_id)
#  index_landings_on_slug            (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (cooperation_id => cooperations.id)
#  fk_rails_...  (institution_id => institutions.id)
#

class Landing < ApplicationRecord
  include WithSlug
  include Archivable

  enum integration: {
    intern: 0,
    iframe: 1,
    api: 2
  }

  enum layout: {
    multiple_steps: 1,
    single_page: 2
  }, _prefix: true

  enum iframe_category: {
    integral: 1,
    themes: 2,
    subjects: 3,
    form: 4
  }, _suffix: :iframe

  ## Associations
  #
  has_many :landing_joint_themes, -> { order(:position) }, inverse_of: :landing, dependent: :destroy
  has_many :landing_themes, through: :landing_joint_themes, inverse_of: :landings
  has_many :landing_subjects, through: :landing_themes, inverse_of: :landing_theme
  has_many :subjects, through: :landing_subjects, inverse_of: :landings

  # TODO : supprimer institution, lié maintenant à cooperation ?
  belongs_to :institution, inverse_of: :landings, optional: true
  belongs_to :cooperation, inverse_of: :landings, optional: true
  # has_one :institution, through: :cooperation, inverse_of: :landings

  has_many :solicitations, inverse_of: :landing
  has_many :diagnoses, through: :solicitations, inverse_of: :landing
  has_many :needs, through: :diagnoses, inverse_of: :landing
  has_many :matches, through: :diagnoses, inverse_of: :landing

  has_one :logo, as: :logoable, dependent: :destroy, inverse_of: :logoable

  accepts_nested_attributes_for :landing_joint_themes, allow_destroy: true

  before_save :set_emphasis

  ## Validation
  #
  validates :slug, presence: true, uniqueness: true
  validates :partner_url, presence: true, if: -> { iframe? || api? }

  ## Scopes
  #
  scope :emphasis, -> { where(emphasis: true) }
  scope :cooperation, -> { where.not(cooperation_id: nil) }

  def self.accueil
    Landing.find_by(slug: 'accueil')
  end

  def to_s
    slug
  end

  def to_param
    slug
  end

  # TODO : delegate ?
  def has_specific_themes?
    landing_themes.any?{ |t| t.has_specific_themes? }
  end

  def has_regional_themes?
    landing_themes.any?{ |t| t.has_regional_themes? }
  end

  # Pour permettre l'affichage de la phrase "voiture-balais" sur les iframes 360
  def displayable_landing_themes
    if self.slug == 'contactez-nous'
      landing_themes
    else
      landing_themes.where.not(slug: 'contactez-nous')
    end
  end

  def update_iframe_360
    return unless self.iframe? && self.integral_iframe?
    self.transaction do
      self.landing_joint_themes.destroy_all
      self.landing_themes << Landing.accueil.landing_themes
      self.landing_themes << LandingTheme.find_by(slug: 'contactez-nous')
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "archived", "archived_at", "created_at", "custom_css", "display_pde_partnership_mention", "emphasis",
      "home_description", "id", "id_value", "iframe_category", "institution_id", "integration", "layout",
      "meta_description", "meta_title", "partner_url", "slug", "title", "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["institution", "landing_joint_themes", "landing_subjects", "landing_themes", "solicitations", "cooperation"]
  end

  private

  def set_emphasis
    if emphasis
      Landing.where.not(id: id).update_all(emphasis: false)
    end
  end
end
