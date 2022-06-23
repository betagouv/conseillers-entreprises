# frozen_string_literal: true

module ApiInsee::SiretsBySiren
  class Base < ApiInsee::Base
    def request()
      ApiInsee::SiretsBySiren::Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiInsee::Request
    private

    def url_key
      @url_key ||= 'siret/'
    end

    def url
      @url ||= "#{base_url}#{url_key}?q=siren:#{@siren_or_siret}"
    end
  end

  class Responder < ApiInsee::Responder
    def format_data
      data = @http_request.data
      etablissements_ouverts = filter_etablissements_ouverts(data["etablissements"])
      {
        'nombre_etablissements' => data.dig('header', 'nombre'),
        'nombre_etablissements_ouverts' => etablissements_ouverts.size,
        'etablissements' => data["etablissements"],
        'etablissements_ouverts' => etablissements_ouverts,
      }
    end

    def filter_etablissements_ouverts(etablissements)
      etablissements_with_openness_data = etablissements.map do |etablissement|
        {
          "siret" => etablissement["siret"],
          "etatAdministratifEtablissement" => etablissement["periodesEtablissement"][0]["etatAdministratifEtablissement"]
        }
      end
      etablissements_with_openness_data.select { |etablissement| etablissement["etatAdministratifEtablissement"] == 'A' }
    end
  end
end
