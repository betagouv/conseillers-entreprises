class Api::V1::LandingSubjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :slug, :landing_id, :landing_theme_id, :landing_theme_slug,
             :description, :description_explanation, :requires_siret, :requires_location

  has_many :additional_subject_questions, key: :questions_additionnelles, serializer: Api::V1::AdditionalSubjectQuestionSerializer
  has_many :solicitable_institutions, key: :institutions_partenaires

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

  def solicitable_institutions
    return [] if object.solicitable_institutions.with_solicitable_logo.empty?
    partenaires = object.solicitable_institutions.with_solicitable_logo.order(:name).reject{ |i| i.opco? }.pluck(:name).uniq
    partenaires << I18n.t('attributes.opco') if object.solicitable_institutions.opco.any?
    partenaires
  end
end
