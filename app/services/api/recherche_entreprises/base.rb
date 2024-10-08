module Api::RechercheEntreprises
  class Base < Api::Base
    attr_reader :query

    def initialize(query, options = {})
      @query = encode_query(query)
      @options = options
    end

    def encode_query(query)
      query = I18n.transliterate(query, locale: :fr)
        .strip
        .squeeze(' ')
      ERB::Util.url_encode(query)
    end

    def handle_error(http_request)
      handle_error_loudly(http_request)
    end
  end

  class Request < Api::Request
    def initialize(query, options = {})
      @query = query
      @options = options
      begin
        @http_response = HTTP.get(url)
        @data = @http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
    end

    def has_tech_error?
      error_code.nil? || (error_code.present? && [429, 500, 501, 502, 503, 504].include?(error_code))
    end

    def data_error_message
      @data['erreur']
    end

    private

    def base_url
      @base_url ||= "https://recherche-entreprises.api.gouv.fr/"
    end

    def url_key
      @url_key ||= ""
    end

    def url
      @url ||= "#{base_url}#{url_key}#{@query}"
    end
  end

  class Responder < Api::Responder
  end
end
