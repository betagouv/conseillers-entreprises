class SearchFacility
  # Recherche d'un établissement via l'appel à des API externes
  # Utilisable pour des champs en auto-complétion
  attr_accessor :query, :non_diffusables

  def initialize(params)
    @query = params[:query]
    @non_diffusables = params[:non_diffusables]
  end

  def from_full_text_or_siren
    return if @query.blank?
    if number_search?
      @query = FormatSiret.clean_siret(@query)
      if siren_search?
        from_siren
      else
        # TODO
        # from_siret
      end
    else
      from_full_text
    end
  end

  def from_siren
    siren = FormatSiret.siren_from_query(query[0..8])
    return if siren.blank?
    begin
      response = ApiInsee::SiretsBySiren::Base.new(siren).call
      response[:etablissements_ouverts].map do |entreprise_params|
        next if entreprise_params.blank?
        ApiConsumption::Models::FacilityAutocomplete::FromApiInsee.new({
          nombre_etablissements_ouverts: response[:nombre_etablissements_ouverts],
          etablissement: entreprise_params.except('uniteLegale'),
          entreprise: entreprise_params['uniteLegale']
        })
      end
    rescue ApiInsee::ApiInseeError => e
      message = e.message.truncate(1000) # Avoid overflowing the cookie_store with alert messages.
      return { error: message }
    end
  end

  private

  def number_search?
    @query.gsub(/\s/, '').match(/^\d+$/)
  end

  def siren_search?
    @query.length < 14
  end

  def from_siret
    siret = FormatSiret.siret_from_query(query[0..13])
    return if siret.blank?
    # TODO
    return { error: I18n.t('api_entreprise.default_error_message.etablissement') }
  end

  def from_full_text
    begin
      response = ApiRechercheEntreprises::Search::Base.new(query).call
      response.map do |entreprise_params|
        next if entreprise_params.blank?
        ApiConsumption::Models::FacilityAutocomplete::FromApiRechercheEntreprises.new(entreprise_params)
      end
    rescue ApiRechercheEntreprises::ApiError => e
      message = e.message.truncate(1000)
      return { error: message }
    end
  end
end
