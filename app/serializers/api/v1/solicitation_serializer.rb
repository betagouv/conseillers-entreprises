class Api::V1::SolicitationSerializer < ActiveModel::Serializer
  attributes :uuid, :code_region, :description, :email, :full_name, :status,
             :location, :phone_number, :siret, :landing_subject, :origin_url

  has_many :subject_answers, key: :questions_additionnelles, serializer: Api::V1::SimpleSubjectAnswerSerializer

  def landing_theme_slug
    object.landing_theme.slug
  end

  def landing_subject
    object.landing_subject.title
  end

  def landing_id
    # Ici, du moment qu'on a une landing_id de l'institution en cours, ca roule
    object.landings.merge(current_institution.landings).first.id
  end

  def subject_questions
    object.subject.subject_questions
  end
end
