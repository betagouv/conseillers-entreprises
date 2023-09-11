# == Schema Information
#
# Table name: experts_subjects
#
#  id                     :bigint(8)        not null, primary key
#  intervention_criteria  :string
#  expert_id              :bigint(8)
#  institution_subject_id :bigint(8)
#
# Indexes
#
#  index_experts_subjects_on_expert_id                             (expert_id)
#  index_experts_subjects_on_expert_id_and_institution_subject_id  (expert_id,institution_subject_id) UNIQUE
#  index_experts_subjects_on_institution_subject_id                (institution_subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (institution_subject_id => institutions_subjects.id)
#
class ExpertSubjectSerializer < ActiveModel::Serializer
  attributes :id, :intervention_criteria, :institution_subject_description, :full_description

  def institution_subject_description
    object.institution_subject.description
  end

  def full_description
    [object.institution_subject, object.intervention_criteria].compact_blank.join(' — ')
  end
end
