# == Schema Information
#
# Table name: subjects
#
#  id                   :integer          not null, primary key
#  archived_at          :datetime
#  interview_sort_order :integer
#  is_support           :boolean          default(FALSE)
#  label                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  theme_id             :bigint(8)        not null
#
# Indexes
#
#  index_subjects_on_archived_at  (archived_at)
#  index_subjects_on_theme_id     (theme_id)
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

  has_many :skills, inverse_of: :subject
  has_many :needs, inverse_of: :subject

  ## Validations
  #
  validates :theme, presence: true
  before_save :set_support

  ## Through Associations
  #
  # :needs
  has_many :diagnoses, through: :needs, inverse_of: :subjects

  ## Scopes
  #
  scope :ordered_for_interview, -> do
    left_outer_joins(:theme)
      .merge(Theme.ordered_for_interview)
      .order(:interview_sort_order, :id)
  end

  scope :for_interview, -> do
    ordered_for_interview
      .archived(false)
      .where(is_support: false)
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

  private

  def set_support
    if is_support
      Subject.where.not(id: id).update_all(is_support: false)
    end
  end
end
