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
  ## JSON Accessors
  #

  CONTENT_KEYS = %w[title subtitle button]
  store_accessor :content, CONTENT_KEYS
end
