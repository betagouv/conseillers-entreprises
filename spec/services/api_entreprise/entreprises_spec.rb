# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiEntreprise::Entreprises do
  let(:company) { described_class.new(token).fetch(siren) }

  let(:httprb_request_headers) do
    { 'Connection' => 'close', 'Host' => 'api.apientreprise.fr', 'User-Agent' => 'http.rb/2.2.2' }
  end

  before { Rails.cache.clear }

  context 'SIREN number exists' do
    let(:token) { '1234' }
    let(:siren) { '123456789' }
    let(:url) { 'https://api.apientreprise.fr/v2/entreprises/123456789?token=1234' }

    before do
      stub_request(:get, url).with(headers: httprb_request_headers).to_return(
        status: 200, headers: {},
        body: File.read(Rails.root.join('spec/fixtures/api_entreprise_get_entreprise.json'))
      )
    end

    it 'creates an entreprise with good fields' do
      expect(company.entreprise.siren).to be_present
      expect(company.entreprise.raison_sociale).to be_present
    end

    it 'has an etablissement_siege with the right fields' do
      expect(company.etablissement_siege.siret).to be_present
    end
  end

  context 'SIREN is missing' do
    let(:token) { '1234' }
    let(:siren) { '' }
    let(:url) { 'https://api.apientreprise.fr/v2/entreprises/?token=1234' }

    before do
      stub_request(:get, url).with(headers: httprb_request_headers).to_return(
        status: 500, headers: {}, body: nil
      )
    end

    it 'raises an error' do
      expect { company }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end

  context 'SIREN does not exist' do
    let(:token) { '1234' }
    let(:siren) { '' }
    let(:url) { 'https://api.apientreprise.fr/v2/entreprises/?token=1234' }

    before do
      stub_request(:get, url).with(headers: httprb_request_headers).to_return(
        status: 500, headers: {},
        body: File.read(Rails.root.join('spec/fixtures/api_entreprise_get_entreprise.json'))
      )
    end

    it 'raises an error' do
      expect { company }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end

  context 'Token is unauthorized' do
    let(:token) { '' }
    let(:siren) { '123456789' }
    let(:url) { 'https://api.apientreprise.fr/v2/entreprises/123456789?token=' }

    before do
      stub_request(:get, url).with(headers: httprb_request_headers).to_return(
        status: 401, headers: {},
        body: File.read(Rails.root.join('spec/fixtures/api_entreprise_get_entreprise_401.json'))
      )
    end

    it 'raises an error' do
      expect { company }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end
end
