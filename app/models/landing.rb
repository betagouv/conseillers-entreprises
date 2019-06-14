# == Schema Information
#
# Table name: landings
#
#  id               :bigint(8)        not null, primary key
#  content          :jsonb
#  featured_on_home :boolean          default(FALSE)
#  home_description :text             default("f")
#  home_sort_order  :integer
#  home_title       :string           default("f")
#  slug             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Landing < ApplicationRecord
  has_many :landing_topics, inverse_of: :landing, :dependent => :destroy

  ## JSON Accessors
  #

  CONTENT_KEYS = %w[meta_title meta_description title subtitle button logos description_example]
  store_accessor :content, CONTENT_KEYS

  accepts_nested_attributes_for :landing_topics, allow_destroy: true

  scope :featured, -> { where(featured_on_home: true) }
  scope :ordered_for_home, -> { where.not(home_sort_order: nil).order(:home_sort_order) }

  def to_s
    slug
  end
end
