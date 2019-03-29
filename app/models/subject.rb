# == Schema Information
#
# Table name: subjects
#
#  id                   :integer          not null, primary key
#  archived_at          :datetime
#  interview_sort_order :integer
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

  ## Through Associations
  #
  # :needs
  has_many :diagnoses, through: :needs, inverse_of: :subjects

  ## Scopes
  #
  scope :ordered_for_interview, -> { order(:interview_sort_order, :id) }

  scope :for_interview, -> do
    ordered_for_interview
      .archived(false)
  end

  ##
  #
  def to_s
    label
  end
end
