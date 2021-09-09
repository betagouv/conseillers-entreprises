# == Schema Information
#
# Table name: landing_joint_themes
#
#  id               :bigint(8)        not null, primary key
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  landing_id       :bigint(8)
#  landing_theme_id :bigint(8)
#
# Indexes
#
#  index_landing_joint_themes_on_landing_id        (landing_id)
#  index_landing_joint_themes_on_landing_theme_id  (landing_theme_id)
#
class LandingJointTheme < ApplicationRecord
  ## Associations
  #
  belongs_to :landing_theme, inverse_of: :landing_joint_themes
  belongs_to :landing, inverse_of: :landing_joint_themes

  acts_as_list scope: :landing
end
