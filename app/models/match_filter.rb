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
#  filtrable_element_type :string
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
    subjects
    raw_accepted_legal_forms
    raw_excluded_legal_forms
    raw_accepted_naf_codes
    raw_excluded_naf_codes
  ]

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

  def raw_accepted_legal_forms=(legal_form_code)
    updated_legal_form_code = legal_form_code.split(/[,\s]/).delete_if(&:empty?)
    self.accepted_legal_forms = updated_legal_form_code
  end

  def raw_excluded_legal_forms=(legal_form_code)
    updated_legal_form_code = legal_form_code.split(/[,\s]/).delete_if(&:empty?)
    self.excluded_legal_forms = updated_legal_form_code
  end

  def same_antenne_or_expert_match_filter?(match_filter_collection)
    # un filtre expert prévaut sur un filtre antenne
    # un filtre antenne prévaut sur un filtre institution
    return false if filtrable_element_type != 'Institution'
    match_filter_collection.any? do |mf|
      mf != self &&
        (((mf.filtrable_element_type == 'Antenne') && mf.filtrable_element.institution_id == filtrable_element.id && mf.has_same_fields_filled?(self)) ||
        (filter_on_expert_exist?(mf))) &&
        mf.has_same_fields_filled?(self)
    end
  end

  def same_expert_match_filter?(match_filter_collection)
    return false if filtrable_element_type != 'Antenne'
    match_filter_collection.any? do |mf|
      mf != self &&
        filter_on_expert_exist?(mf) &&
      mf.has_same_fields_filled?(self)
    end
  end

  def has_same_fields_filled?(other_match_filter)
    fields_to_compare = %i[
      accepted_naf_codes excluded_naf_codes accepted_legal_forms excluded_legal_forms
      effectif_min effectif_max min_years_of_existence max_years_of_existence
    ]
    subjects == other_match_filter.subjects &&
    fields_to_compare.all? do |field|
      self.send(field).present? == other_match_filter.send(field).present?
    end
  end

  private

  def filter_on_expert_exist?(mf)
    mf.filtrable_element_type == 'Expert' && (filtrable_element.experts.exists? mf.filtrable_element.id)
  end
end
