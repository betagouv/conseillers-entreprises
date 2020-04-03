# == Schema Information
#
# Table name: landings
#
#  id               :bigint(8)        not null, primary key
#  content          :jsonb
#  home_description :text             default("f")
#  home_sort_order  :integer
#  home_title       :string           default("f")
#  slug             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_landings_on_slug  (slug) UNIQUE
#

class Landing < ApplicationRecord
  ## Associations
  #
  has_many :landing_topics, inverse_of: :landing, :dependent => :destroy
  has_many :landing_options, inverse_of: :landing, :dependent => :destroy

  has_many :solicitations, primary_key: :slug, foreign_key: :landing_slug, inverse_of: :landing
  accepts_nested_attributes_for :landing_topics, :landing_options, allow_destroy: true

  ## Scopes
  #
  scope :ordered_for_home, -> { where.not(home_sort_order: nil).order(:home_sort_order) }

  ## JSON Accessors
  #
  CONTENT_KEYS = %i[
    meta_title meta_description
    emphasis
    title subtitle button logos
    landing_topic_title
    form_title form_top_message description_example form_bottom_message
    form_promise_message thank_you_message
  ]
  store_accessor :content, CONTENT_KEYS

  def to_s
    slug
  end
end
