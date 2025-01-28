class GetProvenanceDetails
  def initialize(cooperation, query)
    @cooperation = cooperation
    @query = query
  end

  def call
    return [] unless @cooperation.with_provenance_details?
    provenance_details_list.grep(/#{@query}/i)
  end

  private

  def provenance_details_list
    @cooperation.solicitations.pluck(:provenance_detail).compact_blank.uniq
  end
end
