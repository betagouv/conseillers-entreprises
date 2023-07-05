class ExpertSubjectSerializer < ActiveModel::Serializer
  attributes :id, :intervention_criteria, :institution_subject_description, :full_description

  def institution_subject_description
    object.institution_subject.description
  end

  def full_description
    [object.institution_subject, object.intervention_criteria].compact_blank.join(' — ')
  end
end
