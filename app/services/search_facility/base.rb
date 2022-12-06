module SearchFacility
  class Base
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
      raise I18n.l('errors.missing_inherited_method')
    end

    def from_siret
      raise I18n.l('errors.missing_inherited_method')
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

    private

    def number_search?
      @query.gsub(/\s/, '').match(/^\d+$/)
    end

    def siren_search?
      @query.length < 14
    end

    def blank_query
      { items: [], error: I18n.t('api_requests.blank_query') }
    end
  end
end
