# == Schema Information
#
# Table name: badge_badgeables
#
#  id             :bigint(8)        not null, primary key
#  badgeable_type :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  badge_id       :bigint(8)
#  badgeable_id   :bigint(8)        not null
#
# Indexes
#
#  index_badge_badgeables_on_badge_id  (badge_id)
#
# Foreign Keys
#
#  fk_rails_...  (badge_id => badges.id)
#
class BadgeBadgeable < ApplicationRecord
  belongs_to :badge, touch: true
  belongs_to :badgeable, polymorphic: true, touch: true

  after_destroy -> { badgeable.touch }

  def self.ransackable_attributes(auth_object = nil)
    ["badge_id", "badgeable_id", "badgeable_type", "created_at", "id", "id_value", "updated_at"]
  end
end
