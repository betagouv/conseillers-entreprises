# == Schema Information
#
# Table name: match_filters
#
#  id                     :bigint(8)        not null, primary key
#  accepted_naf_codes     :string           is an Array
#  effectif_max           :integer
#  effectif_min           :integer
#  min_years_of_existence :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  antenne_id             :bigint(8)
#  subject_id             :bigint(8)
#
# Indexes
#
#  index_match_filters_on_antenne_id  (antenne_id)
#  index_match_filters_on_subject_id  (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (antenne_id => antennes.id)
#  fk_rails_...  (subject_id => subjects.id)
#
class MatchFilter < ApplicationRecord
  ## Associations
  #
  belongs_to :institution, optional: true
  belongs_to :antenne, optional: true
  belongs_to :subject, optional: true

  has_many :experts, through: :antenne, source: :experts, inverse_of: :match_filters
  has_many :experts_subjects, through: :experts, inverse_of: :match_filters

  def raw_accepted_naf_codes
    accepted_naf_codes&.join(' ')
  end

  def raw_accepted_naf_codes=(naf_codes)
    updated_naf_codes = naf_codes.split(/[,\s]/).delete_if(&:empty?)
    self.accepted_naf_codes = updated_naf_codes
  end
end
