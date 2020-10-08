# == Schema Information
#
# Table name: landing_topics
#
#  id                  :bigint(8)        not null, primary key
#  description         :text
#  group_name          :string
#  landing_option_slug :string
#  landing_sort_order  :integer
#  title               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  landing_id          :bigint(8)        not null
#
# Indexes
#
#  index_landing_topics_on_landing_id  (landing_id)
#
# Foreign Keys
#
#  fk_rails_...  (landing_id => landings.id)
#

class LandingTopic < ApplicationRecord
  belongs_to :landing, inverse_of: :landing_topics, touch: true

  scope :ordered_for_landing, -> { order(:landing_sort_order, :id) }

  ## Class methods for Relations
  #
  def self.grouped_for_landing
    # :group_name and :landing_sort_order are not necessarily consistent.
    # We want to respect landing_sort_order, but group topics with the same group name:
    # the order of the groups is the order in which they appear first in the topics list.
    ordered_landings = current_scope.ordered_for_landing
    ordered_group_names = ordered_landings.pluck(:group_name).uniq
    ordered_group_names.index_with do |group_name|
      ordered_landings.where(group_name: group_name)
    end
  end
end
