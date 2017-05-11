# frozen_string_literal: true

module ApiEntrepriseService
  BASE_URL = 'https://api.apientreprise.fr/v2'

  def self.fetch_company_with_siren(siren)
    raise ParameterMissingError, 'SIREN number is missing' if siren.blank?
    raise CredentialsMissingError, 'API_ENTREPRISE_TOKEN environment variable is missing' if ENV['API_ENTREPRISE_TOKEN'].blank?
    url = "#{BASE_URL}/entreprises/#{siren}?token=#{ENV['API_ENTREPRISE_TOKEN']}"
    JSON.parse open(url).read
  end

  def self.fetch_company_with_siret(siret)
    fetch_company_with_siren siret[0, 9]
  end

  class ParameterMissingError < StandardError; end
  class CredentialsMissingError < StandardError; end
end
