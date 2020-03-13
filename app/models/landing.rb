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

class Landing < ApplicationRecord
  has_many :landing_topics, inverse_of: :landing, :dependent => :destroy

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

  accepts_nested_attributes_for :landing_topics, allow_destroy: true

  scope :ordered_for_home, -> { where.not(home_sort_order: nil).order(:home_sort_order) }

  def to_s
    slug
  end
end
