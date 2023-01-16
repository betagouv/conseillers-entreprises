class Api::V1::SolicitationLogoSerializer < ActiveModel::Serializer
  attributes :institutions_partenaires

  def institutions_partenaires
    return [] if object.landing_subject.solicitable_institutions.with_logo.empty?
    object.landing_subject.solicitable_institutions.with_logo.order(:name).map{ |i| i.opco? ? "OPCO" : i.name }.uniq
  end
end
