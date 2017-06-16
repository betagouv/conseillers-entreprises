# frozen_string_literal: true

require 'rails_helper'

describe UseCases::SearchCompany do
  let(:api_entreprise_fixture) { JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json')) }
  let(:siret) { '41816609600051' }

  describe 'with_siret' do
    it 'calls external service' do
      allow(ApiEntrepriseService).to receive(:fetch_company_with_siret).with(siret) { api_entreprise_fixture }
      described_class.with_siret siret
      expect(ApiEntrepriseService).to have_received(:fetch_company_with_siret).with(siret)
    end
  end

  describe 'with_siret_and_save' do
    it 'calls external service' do
      allow(ApiEntrepriseService).to receive(:fetch_company_with_siret).with(siret) { api_entreprise_fixture }
      described_class.with_siret_and_save siret
      expect(ApiEntrepriseService).to have_received(:fetch_company_with_siret).with(siret)
      expect(Company.last.siren).to eq '418166096'
    end
  end
end
