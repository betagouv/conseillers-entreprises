# frozen_string_literal: true

require 'rails_helper'

describe UseCases::SearchFacility do
  let(:api_entreprise_fixture) do
    JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json'))
  end
  let(:api_entreprise_etablissement_fixture) do
    JSON.parse(File.read('./spec/fixtures/api_entreprise_get_etablissement.json'))
  end
  let(:siret) { '41816609600051' }

  describe 'with_siret' do
    it 'calls external service' do
      allow(ApiEntrepriseService).to receive(:fetch_facility_with_siret).with(siret) do
        api_entreprise_etablissement_fixture
      end

      described_class.with_siret siret

      expect(ApiEntrepriseService).to have_received(:fetch_facility_with_siret).with(siret)
    end
  end

  describe 'with_siret_and_save' do
    before do
      allow(ApiEntrepriseService).to receive(:fetch_company_with_siret).with(siret) do
        api_entreprise_fixture
      end
      allow(ApiEntrepriseService).to receive(:fetch_facility_with_siret).with(siret) do
        api_entreprise_etablissement_fixture
      end
    end

    context 'first call' do
      it 'calls external service' do
        described_class.with_siret_and_save siret

        expect(ApiEntrepriseService).to have_received(:fetch_company_with_siret).with(siret)
        expect(ApiEntrepriseService).to have_received(:fetch_facility_with_siret).with(siret)
        expect(Company.last.siren).to eq siret[0, 9]
        expect(Facility.last.siret).to eq siret
      end
    end

    context 'two calls' do
      it 'does not duplicate Company or Facility' do
        described_class.with_siret_and_save siret
        described_class.with_siret_and_save siret

        expect(Company.count).to eq 1
        expect(Facility.count).to eq 1
      end
    end
  end
end
