class Api::V1::LandingSubjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :slug, :landing_theme_id, :landing_theme_slug,
             :description, :description_explanation, :requires_siret, :requires_location

  def landing_theme_slug
    object.landing_theme.slug
  end
end
