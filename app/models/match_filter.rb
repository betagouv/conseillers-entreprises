# == Schema Information
#
# Table name: match_filters
#
#  id                     :bigint(8)        not null, primary key
#  accepted_legal_forms   :string           is an Array
#  accepted_naf_codes     :string           is an Array
#  effectif_max           :integer
#  effectif_min           :integer
#  excluded_legal_forms   :string           is an Array
#  excluded_naf_codes     :string           is an Array
#  max_years_of_existence :integer
#  min_years_of_existence :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  antenne_id             :bigint(8)
#
# Indexes
#
#  index_match_filters_on_antenne_id  (antenne_id)
#
class MatchFilter < ApplicationRecord
  ## Associations
  #
  belongs_to :antenne, optional: true
  has_and_belongs_to_many :subjects

  has_many :experts, through: :antenne, source: :experts, inverse_of: :match_filters
  has_many :experts_subjects, through: :experts, inverse_of: :match_filters

  def raw_accepted_naf_codes
    accepted_naf_codes&.join(' ')
  end

  def raw_excluded_naf_codes
    excluded_naf_codes&.join(' ')
  end

  def raw_excluded_legal_forms
    excluded_legal_forms&.join(' ')
  end

  def raw_accepted_legal_forms
    accepted_legal_forms&.join(' ')
  end

  def raw_accepted_naf_codes=(naf_codes)
    updated_naf_codes = naf_codes.delete('.').split(/[,\s]/).delete_if(&:empty?)
    self.accepted_naf_codes = updated_naf_codes
  end

  def raw_excluded_naf_codes=(naf_codes)
    updated_naf_codes = naf_codes.delete('.').split(/[,\s]/).delete_if(&:empty?)
    self.excluded_naf_codes = updated_naf_codes
  end

  def raw_accepted_legal_forms=(legal_form_code)
    updated_legal_form_code = legal_form_code.split(/[,\s]/).delete_if(&:empty?)
    self.accepted_legal_forms = updated_legal_form_code
  end

  def raw_excluded_legal_forms=(legal_form_code)
    updated_legal_form_code = legal_form_code.split(/[,\s]/).delete_if(&:empty?)
    self.excluded_legal_forms = updated_legal_form_code
  end
end
