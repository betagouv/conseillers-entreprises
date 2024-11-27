# == Schema Information
#
# Table name: themes
#
#  id                   :bigint(8)        not null, primary key
#  cooperation          :boolean          default(FALSE)
#  interview_sort_order :integer
#  label                :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_themes_on_interview_sort_order  (interview_sort_order)
#  index_themes_on_label                 (label) UNIQUE
#  index_themes_on_updated_at            (updated_at)
#

class Theme < ApplicationRecord
  ## Associations
  #
  has_many :subjects, inverse_of: :theme
  has_many :cooperation_themes, dependent: :destroy, inverse_of: :theme
  has_and_belongs_to_many :territories

  ## Validations
  #
  validates :label, presence: true, uniqueness: true
  after_save :refresh_subjects_slugs

  ## Through Associations
  #
  # :subjects
  has_many :needs, through: :subjects, inverse_of: :theme
  has_many :diagnoses, through: :needs, inverse_of: :themes
  has_many :matches, through: :subjects, inverse_of: :theme
  has_many :institutions_subjects, through: :subjects, inverse_of: :theme
  has_many :landing_subjects, through: :subjects, inverse_of: :themes
  has_many :landing_themes, -> { distinct }, through: :subjects, inverse_of: :themes

  # :institutions_subjects
  has_many :institutions, through: :institutions_subjects, inverse_of: :themes
  has_many :antennes, through: :institutions_subjects, inverse_of: :theme
  has_many :experts_subjects, through: :institutions_subjects, inverse_of: :theme
  has_many :advisors, class_name: 'User', through: :institutions_subjects, source: :users, inverse_of: :themes
  has_many :experts, through: :institutions_subjects, source: :experts, inverse_of: :themes

  ## Scopes
  #
  scope :ordered_for_interview, -> { order(:interview_sort_order, :id) }

  scope :for_interview, -> { ordered_for_interview.where.not(label: "Support") }

  scope :with_territories, -> do
    joins(:territories)
  end

  ##
  #
  def subjects_ordered_for_interview
    # useful for option_groups_from_collection_for_select
    subjects.ordered_for_interview
  end

  def to_s
    label
  end

  def stats_label(detailed)
    detailed = true if detailed.nil?
    # Si on ne veux pas le détail on affiche les thèmes de coopération sous un même label
    !self.cooperation || detailed ? label : I18n.t('activerecord.attributes.theme.stats_label.cooperation')
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "interview_sort_order", "label", "updated_at"]
  end

  private

  def refresh_subjects_slugs
    self.subjects.each do |subject|
      subject.compute_slug && subject.save!
    end
  end
end
