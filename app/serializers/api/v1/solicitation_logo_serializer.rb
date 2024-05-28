class Api::V1::SolicitationLogoSerializer < ActiveModel::Serializer
  attributes :institutions_partenaires

  def institutions_partenaires
    return [] if object.landing_subject.solicitable_institutions.with_solicitable_logo.empty?
    partenaires = object.landing_subject.solicitable_institutions.with_solicitable_logo.order(:name).reject{ |i| i.opco? }.pluck(:name).uniq
    partenaires << I18n.t('attributes.opco') if object.landing_subject.solicitable_institutions.opco.any?
    partenaires
  end
end
