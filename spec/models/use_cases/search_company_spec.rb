# frozen_string_literal: true

require 'rails_helper'

describe UseCases::SearchCompany do
  let(:api_entreprise_fixture) { JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json')) }

  describe 'with_siret' do
    it 'calls external service' do
      siret = '41816609600051'
      allow(ApiEntrepriseService).to receive(:fetch_company_with_siret).with(siret) { api_entreprise_fixture }

      described_class.with_siret siret

      expect(ApiEntrepriseService).to have_received(:fetch_company_with_siret).with(siret)
    end
  end

  describe 'with_siren' do
    it 'calls external service' do
      siren = '418166096'
      allow(ApiEntrepriseService).to receive(:fetch_company_with_siren).with(siren) { api_entreprise_fixture }

      described_class.with_siren siren

      expect(ApiEntrepriseService).to have_received(:fetch_company_with_siren).with(siren)
    end
  end
end
