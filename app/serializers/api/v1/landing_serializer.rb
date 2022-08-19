class Api::V1::LandingSerializer < Api::V1::BaseSerializer
  attributes :id, :title, :slug, :partner_url, :iframe_category
  has_many :landing_themes
end
