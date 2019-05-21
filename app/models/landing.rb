# == Schema Information
#
# Table name: landings
#
#  id         :bigint(8)        not null, primary key
#  content    :jsonb
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Landing < ApplicationRecord
  has_many :landing_topics, inverse_of: :landing, :dependent => :destroy

  ## JSON Accessors
  #

  CONTENT_KEYS = %w[title subtitle button logos]
  store_accessor :content, CONTENT_KEYS

  accepts_nested_attributes_for :landing_topics, allow_destroy: true
end
