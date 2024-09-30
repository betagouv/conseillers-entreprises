module Api::Rne
  class Base < Api::Base
    def initialize(siren_or_siret, options = {})
      siren_or_siret = siren_or_siret[0..8]
      super
    end

    def handle_error(http_request)
      if http_request.has_tech_error?
        notify_tech_error(http_request)
      end
      return { "rne" => { "error" => http_request.error_message } }
    end
  end

  class Request < Api::Request
    def get_url
      HTTP.auth("Bearer #{token}").get(url)
    end

    def token
      @token ||= Api::Rne::Token::Base.new.call
    end

    def has_tech_error?
      @data.present? && @data["errorCode"].nil?
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
      @url ||= "#{base_url}#{url_key}#{@siren_or_siret}"
    end
  end

  class Responder < Api::Responder
  end

end
