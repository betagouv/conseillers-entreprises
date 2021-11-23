# frozen_string_literal: true

module ApiSirene
  class SireneResponse
    def initialize(query, http_response)
      @query = query
      @response = http_response
      begin
        @hashes = http_response.parse(:json)&.deep_symbolize_keys
      rescue StandardError => e
        @error = e
      end
    end

    def success?
      @error.nil? && @response.status.success?
    end

    def error_message
      if !success?
        @error&.message || @response.status.reason
      end
    end

    def suggestions
      suggestions = @hashes[:suggestions] || []
      suggestions.delete(@query)
      suggestions
    end

    def etablissements
      @hashes[:etablissement].map do |h|
        SireneEtablissement.new(h)
      end
    end
  end
end
