class Api::V1::SubjectSerializer < ActiveModel::Serializer
  attributes :id, :label, :slug, :can_be_automated

  class LandingSubjectSerializer < ActiveModel::Serializer # not using Api::V1::LandingSubjectSerializer
    attributes :id, :title, :slug, :description, :description_explanation
  end

  has_many :landing_subjects, serializer: LandingSubjectSerializer do
    object.landing_subjects.filter(&:not_archived?)
  end
end
