class SearchFacility
  # Recherche d'un établissement via l'appel à des API externes
  # Utilisable pour des champs en auto-complétion

  def initialize(params)
    @query = params[:query]
  end

  def from_full_text_or_siren
    return blank_query if @query.blank?
    if number_search?
      @query = FormatSiret.clean_siret(@query)
      if siren_search?
        from_siren
      else
        from_siret
      end
    else
      from_full_text
    end
  end

  def from_siren
    return blank_query if @query.blank?
    siren = FormatSiret.siren_from_query(@query[0..8])
    begin
      response = ApiInsee::SiretsBySiren::Base.new(siren).call
      items = response[:etablissements_ouverts].map do |entreprise_params|
        next if entreprise_params.blank?
        ApiConsumption::Models::FacilityAutocomplete::ApiInsee.new({
          nombre_etablissements_ouverts: response[:nombre_etablissements_ouverts],
          un_seul_etablissement: true,
          etablissement: entreprise_params.except('uniteLegale'),
          entreprise: entreprise_params['uniteLegale']
        })
      end
      return { items: items, error: nil }
    # fallback si l'API Insee est en carafe
    rescue ApiInsee::UnavailableApiError => e
      from_full_text
    rescue ApiInsee::ApiInseeError => e
      message = e.message.truncate(1000) # Avoid overflowing the cookie_store with alert messages.
      return { items: [], error: message }
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
    return blank_query if @query.blank?
    siret = FormatSiret.siret_from_query(@query[0..13])
    begin
      response = ApiInsee::Siret::Base.new(siret).call
      items = response[:etablissements].map do |entreprise_params|
        next if entreprise_params.blank?
        ApiConsumption::Models::FacilityAutocomplete::ApiInsee.new({
          nombre_etablissements_ouverts: response[:nombre_etablissements_ouverts],
          un_seul_etablissement: true,
          etablissement: entreprise_params.except('uniteLegale'),
          entreprise: entreprise_params['uniteLegale']
        })
      end
      return { items: items, error: nil }
    # pas de fallback pour le moment, on trouve pas d'API "equivalente"
    rescue ApiInsee::UnavailableApiError, ApiInsee::ApiInseeError => e
      message = e.message.truncate(1000) # Avoid overflowing the cookie_store with alert messages.
      return { items: [], error: message }
    end
  end

  def from_full_text
    begin
      response = ApiRechercheEntreprises::Search::Base.new(@query).call
      items = response.map do |entreprise_params|
        next if entreprise_params.blank?
        ApiConsumption::Models::FacilityAutocomplete::ApiRechercheEntreprises.new(entreprise_params)
      end
      return { items: items, error: nil }
    rescue ApiRechercheEntreprises::ApiError => e
      message = e.message.truncate(1000)
      return { items: [], error: message }
    end
  end

  def blank_query
    { items: [], error: I18n.t('api_requests.blank_query') }
  end
end
