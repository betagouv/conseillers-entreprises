class ExpertSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :job, :antenne_name
  has_many :experts_subjects, serializer: ExpertSubjectSerializer

  def antenne_name
    object.antenne.name
  end
end
