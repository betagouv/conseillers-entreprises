# == Schema Information
#
# Table name: landing_options
#
#  id                 :bigint(8)        not null, primary key
#  description        :text
#  landing_sort_order :integer
#  slug               :string           not null
#  title              :string
#  landing_id         :bigint(8)
#
# Indexes
#
#  index_landing_options_on_landing_id  (landing_id)
#
# Foreign Keys
#
#  fk_rails_...  (landing_id => landings.id)
#

class LandingOption < ApplicationRecord
  ## Associations
  #
  belongs_to :landing, inverse_of: :landing_options, touch: true

  ## Scopes
  #
  scope :ordered_for_landing, -> { order(:landing_sort_order, :id) }
end
