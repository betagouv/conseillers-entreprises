# frozen_string_literal: true

require 'rails_helper'

describe UseCases::SearchFacility do
  let(:legal_form_code) { '5710' }
  let(:naf_code) { '6202A' }
  let(:code_effectif) { '32' }
  let(:siret) { '41816609600051' }
  let(:siren) { '418166096' }
  let(:token) { '1234' }
  let(:inscrit_rcs) { true }
  let(:inscrit_rm) { true }

  describe 'with_siret' do
    let!(:etablissements_instance) { ApiEntreprise::Etablissements.new(token) }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      allow(ApiEntreprise::Etablissements).to receive(:new).with(token, {}) { etablissements_instance }
      allow(etablissements_instance).to receive(:fetch).with(siret)
    end

    it 'calls external service' do
      described_class.with_siret siret

      expect(ApiEntreprise::Etablissements).to have_received(:new).with(token, {})
      expect(etablissements_instance).to have_received(:fetch).with(siret)
    end
  end

  describe 'with_siret_and_save' do
    before do
      company_json = JSON.parse(file_fixture('api_entreprise_entreprise_request_data.json').read)
      entreprises_instance = ApiEntreprise::EntrepriseWrapper.new(company_json)
      allow(UseCases::SearchCompany).to receive(:with_siret).with(siret, {}) { entreprises_instance }

      facility_json = JSON.parse(file_fixture('api_entreprise_get_etablissement.json').read)
      facility_instance = ApiEntreprise::EtablissementWrapper.new(facility_json)
      allow(described_class).to receive(:with_siret).with(siret, {}) { facility_instance }
    end

    context 'first call' do
      before { described_class.with_siret_and_save siret }

      it 'calls external service' do
        expect(UseCases::SearchCompany).to have_received(:with_siret).with(siret, {})
        expect(described_class).to have_received(:with_siret).with(siret, {})
      end

      it 'sets company and facility' do
        company = Company.last
        facility = Facility.last
        expect(company.siren).to eq siren
        expect(company.legal_form_code).to eq legal_form_code
        expect(company.code_effectif).to eq code_effectif
        expect(company.inscrit_rcs).to eq inscrit_rcs
        expect(company.inscrit_rm).to eq inscrit_rm

        expect(facility.siret).to eq siret
        expect(facility.commune.insee_code).to eq '75102'
        expect(facility.naf_code).to eq naf_code
        expect(facility.code_effectif).to eq code_effectif
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
