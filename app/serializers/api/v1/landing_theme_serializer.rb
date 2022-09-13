class Api::V1::LandingThemeSerializer < ActiveModel::Serializer
  attributes :id, :title, :slug, :description
  has_many :landing_subjects, serializer: Api::V1::LandingSubjectSerializer
end
