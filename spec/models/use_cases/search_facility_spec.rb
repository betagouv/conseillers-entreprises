# frozen_string_literal: true

require 'rails_helper'

describe UseCases::SearchFacility do
  let(:api_entreprise_fixture) { JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json')) }
  let(:api_entreprise_etablissement_fixture) { JSON.parse(File.read('./spec/fixtures/api_entreprise_get_etablissement.json')) }
  let(:siret) { '41816609600051' }

  describe 'with_siret' do
    it 'calls external service' do
      allow(ApiEntrepriseService).to receive(:fetch_facility_with_siret).with(siret) { api_entreprise_etablissement_fixture }
      described_class.with_siret siret
      expect(ApiEntrepriseService).to have_received(:fetch_facility_with_siret).with(siret)
    end
  end

  describe 'with_siret_and_save' do
    it 'calls external service' do
      allow(ApiEntrepriseService).to receive(:fetch_company_with_siret).with(siret) { api_entreprise_fixture }
      allow(ApiEntrepriseService).to receive(:fetch_facility_with_siret).with(siret) { api_entreprise_etablissement_fixture }
      described_class.with_siret_and_save siret
      expect(ApiEntrepriseService).to have_received(:fetch_company_with_siret).with(siret)
      expect(ApiEntrepriseService).to have_received(:fetch_facility_with_siret).with(siret)
      expect(Facility.last.siret).to eq siret
    end
  end
end
