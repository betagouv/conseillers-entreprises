# == Schema Information
#
# Table name: cooperation_themes
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  cooperation_id :bigint(8)        not null
#  theme_id       :bigint(8)        not null
#
# Indexes
#
#  index_cooperation_themes_on_cooperation_id  (cooperation_id)
#  index_cooperation_themes_on_theme_id        (theme_id)
#
# Foreign Keys
#
#  fk_rails_...  (cooperation_id => cooperations.id)
#  fk_rails_...  (theme_id => themes.id)
#
# => Thèmes spécifiques à une coopération, hors des thèmes courants de CE
class CooperationTheme < ApplicationRecord
  belongs_to :cooperation, inverse_of: :cooperation_themes
  belongs_to :theme, inverse_of: :cooperation_themes

  def self.ransackable_attributes(auth_object = nil)
    ["cooperation_id", "theme_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "cooperation", "theme" ]
  end
end
