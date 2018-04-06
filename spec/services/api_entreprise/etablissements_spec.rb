# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiEntreprise::Etablissements do
  let(:facility) { described_class.new(token).fetch(siren) }

  let(:base_url) { 'https://entreprise.api.gouv.fr/v2/etablissements' }
  let(:httprb_request_headers) do
    { 'Connection' => 'close', 'Host' => 'entreprise.api.gouv.fr', 'User-Agent' => 'http.rb/3.0.0' }
  end

  before { Rails.cache.clear }

  context 'SIREN number exists' do
    let(:token) { '1234' }
    let(:siren) { '12345678901234' }
    let(:url) { "#{base_url}/12345678901234?token=1234&context=Reso&recipient=Reso&object=Reso" }

    before do
      stub_request(:get, url).with(headers: httprb_request_headers).to_return(
        status: 200,
        headers: {},
        body: File.read(Rails.root.join('spec', 'fixtures', 'api_entreprise_get_etablissement.json'))
      )
    end

    it 'has the right fields' do
      expect(facility.etablissement.siret).to be_present
    end
  end

  context 'SIREN is missing' do
    let(:token) { '1234' }
    let(:siren) { '' }
    let(:url) { "#{base_url}/?token=1234&context=Reso&recipient=Reso&object=Reso" }

    before do
      stub_request(:get, url).with(headers: httprb_request_headers).to_return(
        status: 500, headers: {}, body: '{}'
      )
    end

    it 'raises an error' do
      expect { facility }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end

  context 'SIREN does not exist' do
    let(:token) { '1234' }
    let(:siren) { '' }
    let(:url) { "#{base_url}/?token=1234&context=Reso&recipient=Reso&object=Reso" }

    before do
      stub_request(:get, url).with(headers: httprb_request_headers).to_return(
        status: 500, headers: {},
        body: File.read(Rails.root.join('spec', 'fixtures', 'api_entreprise_get_entreprise.json'))
      )
    end

    it 'raises an error' do
      expect { facility }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end

  context 'Token is unauthorized' do
    let(:token) { '' }
    let(:siren) { '12345678901234' }
    let(:url) { "#{base_url}/12345678901234?token=&context=Reso&recipient=Reso&object=Reso" }

    before do
      stub_request(:get, url).with(headers: httprb_request_headers).to_return(
        status: 401, headers: {},
        body: File.read(Rails.root.join('spec', 'fixtures', 'api_entreprise_401.json'))
      )
    end

    it 'raises an error' do
      expect { facility }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end
end
