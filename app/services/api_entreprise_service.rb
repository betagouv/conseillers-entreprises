# frozen_string_literal: true

module ApiEntrepriseService
  BASE_URL = 'https://api.apientreprise.fr/v2'

  class << self
    def fetch_company_with_siret(siret)
      fetch_company_with_siren siret[0, 9]
    end

    private

    def fetch_company_with_siren(siren)
      company = Rails.cache.read "company-#{siren}"
      unless company
        company = fetch_company_from_api(siren)
        Rails.cache.write "company-#{siren}", company, expires_in: 12.hours
      end
      company
    end

    def fetch_company_from_api(siren)
      raise ParameterMissingError, 'SIREN number is missing' if siren.blank?
      raise CredentialsMissingError, 'API_ENTREPRISE_TOKEN environment variable is missing' if ENV['API_ENTREPRISE_TOKEN'].blank?
      url = "#{BASE_URL}/entreprises/#{siren}?token=#{ENV['API_ENTREPRISE_TOKEN']}"
      JSON.parse open(url).read
    end
  end

  class ParameterMissingError < StandardError; end
  class CredentialsMissingError < StandardError; end
end
