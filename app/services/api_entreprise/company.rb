# frozen_string_literal: true

module ApiEntreprise
  class Asset
    attr_reader :company_h
    def initialize(company_h)
      @company_h = company_h
      company_h.each do |method, value|
        self.class.send(:define_method, method.underscore.to_sym) do
          value
        end
      end
    end
  end

  class Company
    attr_reader :entreprise, :etablissement_siege
    class Company < Asset; end
    class HeadOffice < Asset; end

    def initialize(company_h)
      return unless company_h.present?
      @entreprise = Company.new(company_h.fetch('entreprise', {}))
      @etablissement_siege = HeadOffice.new(company_h.fetch('etablissement_siege', {}))
    end

    def present?
      entreprise || etablissement_siege
    end

    def self.from_siret(siret)
      siren = siret[0..8]
      new Request.new(siren).process
    end

    class Request
      attr_accessor :siren

      BASE_URL = 'https://api.apientreprise.fr/v2'

      def initialize(siren)
        @siren = siren
      end

      def process
        Rails.cache.fetch("company-#{siren}") do
          JSON.parse open(url).read
        end
      rescue OpenURI::HTTPError
        nil
      end

      private

      def url
        token = ENV['API_ENTREPRISE_TOKEN']
        raise CredentialsMissingError if token.blank?
        raise SirenMissingError if siren.blank?
        "#{BASE_URL}/entreprises/#{siren}?token=#{token}"
      end

      class CredentialsMissingError < StandardError
        def message
          'API_ENTREPRISE_TOKEN environment variable is missing'
        end
      end

      class SirenMissingError < StandardError
        def message
          'Missing siren'
        end
      end
    end
  end
end
