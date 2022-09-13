class Api::V1::LandingSubjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :slug,
             :description, :description_explanation, :requires_siret, :requires_location
end
