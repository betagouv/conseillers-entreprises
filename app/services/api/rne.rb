module Api::Rne
  class Base < Api::Base
    def initialize(query, options = {})
      query = query[0..8]
      super
    end
  end

  class Request < Api::Request
    def get_url
      HTTP.auth("Bearer #{token}").get(url)
    end

    def token
      @token ||= Api::Rne::Token::Base.new.call
    end

    def data_error_message
      @data["message"]
    end

    private

    def base_url
      @base_url ||= "https://registre-national-entreprises.inpi.fr/api/"
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
