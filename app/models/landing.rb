# == Schema Information
#
# Table name: landings
#
#  id               :bigint(8)        not null, primary key
#  content          :jsonb
#  home_description :text             default("")
#  home_sort_order  :integer
#  home_title       :string           default("")
#  slug             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  institution_id   :bigint(8)
#
# Indexes
#
#  index_landings_on_institution_id  (institution_id)
#  index_landings_on_slug            (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#

class Landing < ApplicationRecord
  ## Associations
  #
  belongs_to :institution, inverse_of: :landings, optional: true
  has_many :landing_topics, inverse_of: :landing, :dependent => :destroy
  has_many :landing_options, inverse_of: :landing, :dependent => :destroy

  has_many :solicitations, primary_key: :slug, foreign_key: :landing_slug, inverse_of: :landing
  accepts_nested_attributes_for :landing_topics, :landing_options, allow_destroy: true

  before_save :set_emphasis

  ## Scopes
  #
  scope :ordered_for_home, -> { where.not(home_sort_order: nil).order(:home_sort_order) }

  scope :emphasis, -> { where("content->>'emphasis' = '1'") }

  ## JSON Accessors
  #
  CONTENT_KEYS = %i[
    meta_title meta_description
    emphasis
    title subtitle logos
    custom_css
    landing_topic_title message_under_landing_topics
    description_example form_bottom_message
    form_promise_message thank_you_message
  ]
  store_accessor :content, CONTENT_KEYS

  def to_s
    slug
  end

  def to_param
    slug
  end

  private

  def set_emphasis
    if emphasis
      Landing.where.not(id: id).each { |l| l.update(emphasis: false) }
    end
  end
end
