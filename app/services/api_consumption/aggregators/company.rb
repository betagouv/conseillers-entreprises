module ApiConsumption::Aggregators
  class Company
    REQUESTS = {
      api_entreprise_entreprise: Api::ApiEntreprise::Entreprise::Base, # raises technical error in case of failure because severity is major
      api_entreprise_effectifs_annuel: Api::ApiEntreprise::EntrepriseEffectifAnnuel::Base,
      api_entreprise_mandataires_sociaux: Api::ApiEntreprise::EntrepriseMandatairesSociaux::Base,
      api_rne_companies: Api::Rne::Companies::Base,
    }

    def initialize(siren, options = {})
      @siren = siren
      @options = options
    end

    def item_params
      Parallel.map(request_keys, in_threads: request_keys.size) do |request_key|
        request_klass = REQUESTS[request_key]
        begin
          request_klass.new(@siren).call
        rescue StandardError => e
          { errors: { unreachable_apis: {request_key => e.message} } }
        end
      end.each_with_object(base_hash.with_indifferent_access) do |response, hash|
        # rescue BasicError and StandardError here, and accumulate errors like the minor errors.
        # additionally, do not actually deep merge: tag the stuff with the “request” (the api)?
        #
        # En fait, non: on ne sait pas _à l’avance_ quels sont les apis qui retournent quels champs.
        # la méthode format_data passe les hash tels quels. Si un champ manque dans la réponse finale, on ne sait pas dire quelle api aurait du le remplire.
        #
        # Bref:
        # on peut quand même catcher les TechnicalErrors ici et les afficher comme erreurs.
        hash["entreprise"].deep_merge! response
      end
    end

    private

    def base_key
      @options&.dig(:base_key) || :api_entreprise_entreprise
    end

    def base_hash
      @base_hash ||= REQUESTS[base_key].new(@siren).call
    end

    def request_keys
      @options&.dig(:request_keys) || REQUESTS.keys.excluding(base_key)
    end

    def requests
      REQUESTS.slice(*request_keys).values
    end
  end
end
