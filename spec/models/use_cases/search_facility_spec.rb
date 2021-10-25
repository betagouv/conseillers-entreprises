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
    let!(:api_facility) { ApiConsumption::Facility.new(siret) }

    before do
      allow(ApiConsumption::Facility).to receive(:new).with(siret, {}) { api_facility }
      allow(api_facility).to receive(:call)
    end

    it 'calls external service' do
      described_class.with_siret siret

      expect(ApiConsumption::Facility).to have_received(:new).with(siret, {})
      expect(api_facility).to have_received(:call)
    end
  end

  describe 'with_siret_and_save' do
    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      company_json = JSON.parse(file_fixture('api_entreprise_entreprise_request_data.json').read)
      entreprises_instance = ApiEntreprise::EntrepriseWrapper.new(company_json)
      allow(UseCases::SearchCompany).to receive(:with_siret).with(siret, {}) { entreprises_instance }

      api_entreprise_facility_json = JSON.parse(file_fixture('api_entreprise_get_etablissement.json').read)
      allow(ApiEntreprise::EtablissementRequest).to receive(:new).with(token, siret, HTTP, {})
      allow(ApiEntreprise::EtablissementRequest.new(token, siret, HTTP, {})).to receive(:response) { ApiEntreprise::EtablissementResponse.new({ fake: 'fake' }) }
      allow(ApiEntreprise::EtablissementResponse).to receive(:new).with({ fake: 'fake' }) { OpenStruct.new({ data: api_entreprise_facility_json, success?: true }) }
      allow(ApiEntreprise::EtablissementResponse.new({ fake: 'fake' })).to receive(:success?).and_return(true)

      cfadock_json = JSON.parse(file_fixture('api_cfadock_get_opco.json').read)
      # Je sais pas pourquoi, mais sans appel prene trouve préalable à la classe,
      # rspec considere ApiCfadock::QueryFilter comme non instancié
      ApiCfadock::GetOpco
      api_cfadock_queryfilter = ApiCfadock::QueryFilter.new(cfadock_json)
      allow(ApiCfadock::GetOpco).to receive(:call).with(siret) { api_cfadock_queryfilter }

      facility_adapter_json = JSON.parse(file_fixture('api_facility_adapter.json').read)
      facility_instance = ApiConsumption::Models::Facility.new(facility_adapter_json)
      allow(described_class).to receive(:with_siret).with(siret, {}) { facility_instance }
    end

    context 'first call' do
      let!(:opco) { create :opco, siren: "851296632" }

      before do
        described_class.with_siret_and_save siret
      end

      it 'calls external service' do
        expect(UseCases::SearchCompany).to have_received(:with_siret).with(siret, {})
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
        expect(facility.opco).to eq opco
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
