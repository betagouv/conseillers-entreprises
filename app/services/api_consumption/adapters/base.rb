module ApiConsumption::Adapters
  class Base
    def api_entreprise_token
      ENV.fetch('API_ENTREPRISE_TOKEN')
    end
  end
end
