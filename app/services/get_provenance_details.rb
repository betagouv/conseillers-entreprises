class GetProvenanceDetails
  # item peut être un user ou une institution
  def initialize(cooperation, query)
    @cooperation = cooperation
    @query = query
  end

  def call
    return unless @cooperation.with_provenance_details?
    return results(entreprendre_provenance_details) if @cooperation.id == 1
    return results(les_aides_provenance_details) if @cooperation.id == 3  
    return results(mtee_provenance_details) if @cooperation.id == 4
  end


  private

  def results(provenance_details)
    provenance_details.grep(/#{@query}/i).map{|s| [s, s] }
  end

  # On ne veut que les fiches en F
  def entreprendre_provenance_details
    @entreprendre_provenance_details ||= @cooperation.solicitations.map{|s| s.mtm_kwd }.compact_blank.uniq
  end

  def les_aides_provenance_details
    @les_aides_provenance_details ||= @cooperation.solicitations.map{|s| s.origin_title }.compact_blank.uniq
  end

  def mtee_provenance_details
    @mtee_provenance_details ||= @cooperation.solicitations.map{|s| s.origin_url.gsub("https://mission-transition-ecologique.beta.gouv.fr/", "") }.compact_blank.uniq
  end
end
