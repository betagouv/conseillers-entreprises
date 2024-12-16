# == Schema Information
#
# Table name: badges
#
#  id         :bigint(8)        not null, primary key
#  category   :integer          not null
#  color      :string           default("#000000"), not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_badges_on_title_and_category  (title,category) UNIQUE
#

class Badge < ApplicationRecord
  enum :category, {
    solicitations: 0, needs: 1
  }, prefix: true

  ## Associations
  #
  has_many :badge_badgeables, dependent: :destroy
  has_many :solicitations, through: :badge_badgeables, source_type: 'Solicitation', source: :badgeable
  has_many :needs, through: :badge_badgeables, source_type: 'Need', source: :badgeable

  ## Callbacks
  #
  after_update -> do
    solicitations.each(&:touch)
    needs.each(&:touch)
  end

  ## Validations
  #
  validates :title, :color, :category, presence: true, allow_blank: false
  validates :title, uniqueness: { scope: :category }

  ##
  #
  def to_s
    title
  end
end
