# frozen_string_literal: true

require 'rails_helper'

describe UseCases::SearchCompany do
  let(:siren) { '123456789' }

  describe 'with_siren' do
    let(:token) { '1234' }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token

      stub_request(
        :get, 'https://api.apientreprise.fr/v2/entreprises/123456789?token=1234'
      ).with(
        headers: { 'Connection' => 'close', 'Host' => 'api.apientreprise.fr', 'User-Agent' => 'http.rb/2.2.2' }
      ).to_return(
        status: 200, headers: {},
        body: File.read(Rails.root.join('spec/fixtures/api_entreprise_get_entreprise.json'))
      )
    end

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
end
