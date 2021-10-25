module ApiConsumption::Adapters
  class Facility < Base
    attr_accessor :etablissement_params

    def initialize(siret, options = {})
      @siret = siret
      @options = options

      opco_params = fetch_opco_params
      api_entreprise_etablissement_params = fetch_api_entreprise_params
      @etablissement_params = api_entreprise_etablissement_params.merge(opco_params)
    end

    private

    def fetch_api_entreprise_params
      connection = HTTP
      response = ApiEntreprise::EtablissementRequest.new(api_entreprise_token, @siret, connection, @options).response
      raise ApiEntreprise::ApiEntrepriseError, response.error_message if !response.success?
      response.data["etablissement"]
    end

    def fetch_opco_params
      full_data = ApiCfadock::GetOpco.call(@siret)
      full_data&.data || {}
    end
  end
end
