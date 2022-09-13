class Api::V1::LandingSerializer < ActiveModel::Serializer
  attributes :id, :title, :slug, :partner_url
  has_many :landing_themes, serializer: Api::V1::LandingThemeSerializer
end
