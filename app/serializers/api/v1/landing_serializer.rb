class Api::V1::LandingSerializer < ActiveModel::Serializer
  attributes :id, :title, :slug, :partner_url, :iframe_category
  has_many :landing_themes
end
