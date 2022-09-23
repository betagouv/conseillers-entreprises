class Api::V1::LandingSubjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :slug, :landing_id, :landing_theme_id, :landing_theme_slug,
             :description, :description_explanation, :requires_siret, :requires_location

  has_many :additional_subject_questions, key: :questions_additionnelles, serializer: Api::V1::AdditionalSubjectQuestionSerializer

  def landing_theme_slug
    object.landing_theme.slug
  end

  def landing_id
    # Ici, du moment qu'on a une landing_id de l'institution en cours, ca roule
    object.landings.merge(current_institution.landings).first.id
  end

  def additional_subject_questions
    object.subject.additional_subject_questions
  end
end
