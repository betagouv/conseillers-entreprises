# == Schema Information
#
# Table name: experts
#
#  id             :bigint(8)        not null, primary key
#  deleted_at     :datetime
#  email          :string
#  full_name      :string
#  is_global_zone :boolean          default(FALSE)
#  job            :string
#  phone_number   :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  antenne_id     :bigint(8)        not null
#
# Indexes
#
#  index_experts_on_antenne_id  (antenne_id)
#  index_experts_on_deleted_at  (deleted_at)
#  index_experts_on_email       (email)
#
# Foreign Keys
#
#  fk_rails_...  (antenne_id => antennes.id)
#
class ExpertSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :job, :antenne_name
  has_many :experts_subjects, serializer: ExpertSubjectSerializer

  def antenne_name
    object.antenne.name
  end
end
