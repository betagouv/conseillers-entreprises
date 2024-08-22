module MatchFilters
  extend ActiveSupport::Concern

  def self.filters
    %i[
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
  end
end
