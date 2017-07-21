# frozen_string_literal: true

require 'rails_helper'

describe ApiEntrepriseService do
  describe 'fetch_company_with_siren and siret' do
    let(:url) { 'https://api.apientreprise.fr/v2/entreprises/123456789?token=awesome_secured_token' }
    let(:api_entreprise_json) { '{ok: true}' }
    let(:siren) { '123456789' }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = 'awesome_secured_token'
      allow(described_class).to receive(:open).with(url) { File }
      allow(File).to receive(:read) { api_entreprise_json }
      allow(JSON).to receive(:parse).with(api_entreprise_json)
    end

    after do
      expect(described_class).to have_received(:open)
      expect(File).to have_received(:read)
      expect(JSON).to have_received(:parse)
    end

    describe 'fetch_company_with_siret' do
      let(:siret) { '12345678901234' }

      it { described_class.fetch_company_with_siret siret }
    end

    describe 'fetch_company_with_siren' do
      it { described_class.send(:fetch_cache_company_with_siren, siren) }
    end
  end

  describe 'fetch_company_with_siren' do
    it do
      siren = '418166096'
      siret = '41816609600051'
      api_json = JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json'))
      allow(described_class).to receive(:fetch_cache_company_with_siren).with(siren) { api_json }

      result = described_class.fetch_company_with_siren siren

      expect(described_class).to have_received(:fetch_cache_company_with_siren).with(siren) { api_json }
      expect(result['entreprise']['siret_siege_social']).to eq siret
    end
  end

  describe 'fetch_facility_with_siret' do
    let(:url) { 'https://api.apientreprise.fr/v2/etablissements/12345678901234?token=awesome_secured_token' }
    let(:api_entreprise_json) { '{ok: true}' }
    let(:siret) { '12345678901234' }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = 'awesome_secured_token'
      allow(described_class).to receive(:open).with(url) { File }
      allow(File).to receive(:read) { api_entreprise_json }
      allow(JSON).to receive(:parse).with(api_entreprise_json)
    end

    after do
      expect(described_class).to have_received(:open)
      expect(File).to have_received(:read)
      expect(JSON).to have_received(:parse)
    end

    describe 'fetch_facility_with_siret' do
      let(:siret) { '12345678901234' }

      it { described_class.fetch_facility_with_siret siret }
    end
  end

  describe 'company_name' do
    subject(:company_name) { described_class.company_name company_json }

    let(:company) { build :company }

    context 'no social name' do
      let(:company_json) { { 'entreprise' => { 'nom_commercial' => company.name, 'raison_sociale' => '' } } }

      it { is_expected.to eq company.name.titleize }
    end

    context 'no commercial name' do
      let(:company_json) { { 'entreprise' => { 'nom_commercial' => '', 'raison_sociale' => company.name } } }

      it { is_expected.to eq company.name.titleize }
    end

    context 'empty values' do
      let(:company_json) { { 'entreprise' => { 'nom_commercial' => '', 'raison_sociale' => '' } } }

      it { is_expected.to eq nil }
    end

    context 'empty entreprise hash' do
      let(:company_json) { { 'entreprise' => {} } }

      it { is_expected.to eq nil }
    end

    context 'empty json' do
      let(:company_json) { {} }

      it { is_expected.to eq nil }
    end
  end

  describe 'facility_location' do
    subject(:facility_location) { described_class.facility_location facility_json }

    context 'normal case' do
      let(:facility_json) { { 'commune_implantation' => { 'code' => '75108', 'value' => 'PARIS 8' } } }

      it { is_expected.to eq '75108 Paris 8' }
    end

    context 'empty values' do
      let(:facility_json) { { 'commune_implantation' => { 'code' => '', 'value' => '' } } }

      it { is_expected.to eq nil }
    end

    context 'empty commune hash' do
      let(:facility_json) { { 'commune_implantation' => {} } }

      it { is_expected.to eq nil }
    end

    context 'empty json' do
      let(:facility_json) { {} }

      it { is_expected.to eq nil }
    end
  end
end
