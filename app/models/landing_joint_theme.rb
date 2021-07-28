class LandingJointTheme< ApplicationRecord
  ## Associations
  #
  belongs_to :landing_theme, inverse_of: :landing_joint_themes
  belongs_to :landing, inverse_of: :landing_joint_themes

  acts_as_list scope: :landing

end
