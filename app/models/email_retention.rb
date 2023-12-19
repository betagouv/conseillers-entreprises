# == Schema Information
#
# Table name: email_retentions
#
#  id                   :bigint(8)        not null, primary key
#  email_subject        :string           not null
#  first_paragraph      :text             not null
#  first_subject_label  :string           not null
#  second_subject_label :string           not null
#  waiting_time         :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  first_subject_id     :bigint(8)        not null
#  second_subject_id    :bigint(8)        not null
#  subject_id           :bigint(8)        not null
#
# Indexes
#
#  index_email_retentions_on_first_subject_id   (first_subject_id)
#  index_email_retentions_on_second_subject_id  (second_subject_id)
#  index_email_retentions_on_subject_id         (subject_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (first_subject_id => subjects.id)
#  fk_rails_...  (second_subject_id => subjects.id)
#  fk_rails_...  (subject_id => subjects.id)
#
class EmailRetention < ApplicationRecord
  belongs_to :subject
  belongs_to :first_subject, class_name: 'Subject'
  belongs_to :second_subject, class_name: 'Subject'

  validates :subject, uniqueness: true
  validates :waiting_time, :first_subject_label, :second_subject_label, :first_paragraph, :email_subject, presence: true, allow_blank: false

  def self.ransackable_attributes(auth_object = nil)
    [
      "created_at", "email_subject", "first_paragraph", "first_subject_id", "first_subject_label", "id", "id_value",
      "second_subject_id", "second_subject_label", "subject_id", "updated_at", "waiting_time"
    ]
  end
end
