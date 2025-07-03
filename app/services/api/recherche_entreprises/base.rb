module Api::RechercheEntreprises
  class Base < Api::Base
    attr_reader :query

    def initialize(query, options = {})
      p "initialize Base #{self.class.name}"
      @query = encode_query(query)
      @options = options
    end

    def encode_query(query)
      query = I18n.transliterate(query, locale: :fr)
        .strip
        .squeeze(' ')
      ERB::Util.url_encode(query)
    end

    def severity
      :major
    end
  end

  class Request < Api::Request
    def initialize(query, options = {})
      p "initialize Request #{self.class.name}"
      @query = query
      @options = options
      begin
        @http_response = HTTP.get(url)
        @data = @http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
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
