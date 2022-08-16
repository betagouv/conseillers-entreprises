class LandingSerializer < ActiveModel::Serializer
  attributes :id, :title, :slug, :partner_url, :iframe_category
end
