# == Schema Information
#
# Table name: referencement_coverages
#
#  id                     :bigint(8)        not null, primary key
#  anomalie               :integer
#  anomalie_details       :json
#  coverage               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  antenne_id             :bigint(8)        not null
#  institution_subject_id :bigint(8)        not null
#
# Indexes
#
#  index_referencement_coverages_on_antenne_id              (antenne_id)
#  index_referencement_coverages_on_institution_subject_id  (institution_subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (antenne_id => antennes.id)
#  fk_rails_...  (institution_subject_id => institutions_subjects.id)
#
class ReferencementCoverage < ApplicationRecord
  belongs_to :antenne
  belongs_to :institution_subject

  enum anomalie: { no_anomalie: 0, no_expert: 1, missing_insee_codes: 2, extra_insee_codes: 3, no_user: 4 }
end
