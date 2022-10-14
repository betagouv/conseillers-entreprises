class Api::V1::SolicitationLogoSerializer < ActiveModel::Serializer
  attributes :institutions_partenaires

  def institutions_partenaires
    return [] if object.landing_subject.logos.empty?
    object.landing_subject.logos.map{ |l| l.institution&.opco? ? "OPCO" : l.institution&.name }.uniq
  end
end
