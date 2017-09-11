# frozen_string_literal: true

require 'rails_helper'

describe UseCases::SearchCompany do
  let(:siren) { '123456789' }

  describe 'with_siren' do
    let(:token) { '1234' }

    before { ENV['API_ENTREPRISE_TOKEN'] = token }

    it 'calls external service' do
      entreprises_instance = ApiEntreprise::Entreprises.new(token)

      allow(ApiEntreprise::Entreprises).to receive(:new).with(token) { entreprises_instance }
      allow(entreprises_instance).to receive(:fetch).with(siren)

      described_class.with_siren siren

      expect(ApiEntreprise::Entreprises).to have_received(:new).with(token)
      expect(entreprises_instance).to have_received(:fetch).with(siren)
    end
  end

  describe 'with_siret' do
    it 'calls external service' do
      siret = '12345678901234'
      allow(described_class).to receive(:with_siren).with(siren)

      described_class.with_siret siret

      expect(described_class).to have_received(:with_siren).with(siren)
    end
  end

  describe 'with_name_and_county' do
    let(:name) { 'Octo' }
    let(:county) { '75' }

    it 'calls external service' do
      firms_instance = Firmapi::FirmsSearch.new
      firms_json = JSON.parse(File.read(Rails.root.join('spec/fixtures/firmapi_get_firms.json')))

      allow(Firmapi::FirmsSearch).to receive(:new) { firms_instance }
      allow(firms_instance).to receive(:fetch).with(name, county) { Firmapi::Firms.new(firms_json) }

      described_class.with_name_and_county name, county

      expect(Firmapi::FirmsSearch).to have_received(:new)
      expect(firms_instance).to have_received(:fetch).with(name, county)
    end
  end
end
