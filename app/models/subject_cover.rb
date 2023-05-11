# == Schema Information
#
# Table name: subject_covers
#
#  id                     :bigint(8)        not null, primary key
#  anomalie               :integer
#  anomalie_details       :json
#  cover                  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  antenne_id             :bigint(8)        not null
#  institution_subject_id :bigint(8)        not null
#
# Indexes
#
#  index_subject_covers_on_antenne_id              (antenne_id)
#  index_subject_covers_on_institution_subject_id  (institution_subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (antenne_id => antennes.id)
#  fk_rails_...  (institution_subject_id => institutions_subjects.id)
#
class SubjectCover < ApplicationRecord
  belongs_to :antenne
  belongs_to :institution_subject

  enum anomalie: { less: 0, less_specific: 1, more: 2, more_specific: 3 }
end
