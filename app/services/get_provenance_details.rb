class GetProvenanceDetails
  def initialize(cooperation, query)
    @cooperation = cooperation
    @query = query
  end

  def call
    return [] unless @cooperation.with_provenance_details?
    sanitized_query = Regexp.escape(@query)
    provenance_details_list.grep(/#{sanitized_query}/i)
  end

  private

  def provenance_details_list
    @cooperation.solicitations.pluck(:provenance_detail).compact_blank.uniq
  end
end
