# frozen_string_literal: true

module ApiEntreprise
  class Request
    attr_accessor :siret

    BASE_URL = 'https://api.apientreprise.fr/v2'

    def initialize(siret)
      @siret = siret
    end

    def process
      Rails.cache.fetch("company-#{siret}", expires_in: 12.hours) do
        JSON.parse open(url).read
      end
    rescue OpenURI::HTTPError
      nil
    end

    private

    def url
      token = ENV['API_ENTREPRISE_TOKEN']
      raise CredentialsMissingError if token.blank?
      raise SirenMissingError if siret.blank?
      "#{BASE_URL}/entreprises/#{siret}?token=#{token}"
    end

    class CredentialsMissingError < StandardError
      def message
        'API_ENTREPRISE_TOKEN environment variable is missing'
      end
    end

    class SirenMissingError < StandardError
      def message
        'Missing SIREN number'
      end
    end
  end
end
