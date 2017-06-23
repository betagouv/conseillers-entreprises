# frozen_string_literal: true

module ApiEntrepriseService
  BASE_URL = 'https://api.apientreprise.fr/v2'

  class << self
    def fetch_company_with_siret(siret)
      fetch_cache_company_with_siren siret[0, 9]
    end

    def fetch_facility_with_siret(siret)
      fetch_cache_facility_with_siret siret
    end

    def company_name(company_json)
      company_name = company_json['entreprise']['nom_commercial']
      company_name = company_json['entreprise']['raison_sociale'] if company_name.blank?
      company_name
    end

    private

    def fetch_cache_company_with_siren(siren)
      company = Rails.cache.read "company-#{siren}"
      unless company
        company = fetch_company_from_api(siren)
        Rails.cache.write "company-#{siren}", company, expires_in: 12.hours
      end
      company
    end

    def fetch_company_from_api(siren)
      raise ParameterMissingError, 'SIREN number is missing' if siren.blank?
      check_credentials
      url = "#{BASE_URL}/entreprises/#{siren}?token=#{ENV['API_ENTREPRISE_TOKEN']}"
      JSON.parse open(url).read
    end

    def fetch_cache_facility_with_siret(siret)
      facility = Rails.cache.read "facility-#{siret}"
      unless facility
        facility = fetch_facility_from_api(siret)
        Rails.cache.write "facility-#{siret}", facility, expires_in: 12.hours
      end
      facility
    end

    def fetch_facility_from_api(siret)
      raise ParameterMissingError, 'SIRET number is missing' if siret.blank?
      check_credentials
      url = "#{BASE_URL}/etablissements/#{siret}?token=#{ENV['API_ENTREPRISE_TOKEN']}"
      JSON.parse open(url).read
    end

    def check_credentials
      raise CredentialsMissingError, 'API_ENTREPRISE_TOKEN environment variable is missing' if ENV['API_ENTREPRISE_TOKEN'].blank?
    end
  end

  class ParameterMissingError < StandardError; end
  class CredentialsMissingError < StandardError; end
end
