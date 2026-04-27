# == Schema Information
#
# Table name: match_filters
#
#  id                     :bigint(8)        not null, primary key
#  accepted_legal_forms   :string           is an Array
#  accepted_naf_codes     :string           is an Array
#  effectif_max           :integer
#  effectif_min           :integer
#  excluded_insee_codes   :string           default([]), is an Array
#  excluded_legal_forms   :string           is an Array
#  excluded_naf_codes     :string           is an Array
#  filtrable_element_type :string           not null
#  max_years_of_existence :integer
#  min_years_of_existence :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  filtrable_element_id   :bigint(8)        not null
#
# Indexes
#
#  index_match_filters_on_filtrable_element  (filtrable_element_type,filtrable_element_id)
#
class MatchFilter < ApplicationRecord
  ## Associations
  #
  belongs_to :filtrable_element, polymorphic: true
  has_and_belongs_to_many :subjects

  FILTERS = %i[
    min_years_of_existence
    max_years_of_existence
    effectif_min
    effectif_max
    raw_accepted_legal_forms
    raw_excluded_legal_forms
    raw_accepted_naf_codes
    raw_excluded_naf_codes
    raw_excluded_insee_codes
    subjects
  ]

  def filter_types
    FILTERS.select { |filter| self.send(filter).present? }
  end

  def experts_subjects
    ExpertSubject.where(expert_id: experts.ids)
  end

  def experts
    filtrable_element.experts
  end

  def expert=(expert)
    self.filtrable_element = expert
  end

  def antenne
    filtrable_element if filtrable_element_type == 'Antenne'
  end

  def antenne=(antenne)
    self.filtrable_element = antenne
  end

  def institution
    filtrable_element if filtrable_element_type == 'Institution'
  end

  def institution=(institution)
    self.filtrable_element = institution
  end

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

  def raw_excluded_insee_codes
    excluded_insee_codes&.join(' ')
  end

  def raw_excluded_insee_codes=(insee_codes)
    normalized = FormatInseeCodes.normalize(insee_codes)
    self.excluded_insee_codes = normalized.split.delete_if(&:empty?)
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
