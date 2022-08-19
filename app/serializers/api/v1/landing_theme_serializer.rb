class Api::V1::LandingThemeSerializer < Api::V1::ActiveModel::Serializer
  attributes :id, :title, :slug
end
