# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiEntreprise::Etablissement::Base do
  let(:facility) { described_class.new(siret).call[:etablissement] }
  let(:base_url) { 'https://entreprise.api.gouv.fr/v3/insee/sirene/etablissements' }
  let(:url) { "#{base_url}/#{siret}?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013" }

  context 'SIREN number exists' do
    let(:token) { '1234' }
    let(:siret) { '41816609600069' }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, url).to_return(
        body: file_fixture('api_entreprise_etablissement.json')
      )
    end

    it 'has the right fields' do
      expect(facility["siret"]).to be_present
    end
  end

  context 'SIRET is missing' do
    let(:token) { '1234' }
    let(:siret) { '' }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, url).to_return(
        status: 500, body: '{}'
      )
    end

    it 'raises an error' do
      expect { facility }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end

  context 'SIRET does not exist' do
    let(:token) { '1234' }
    let(:siret) { '12345678901234' }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, url).to_return(
        status: 500,
        body: file_fixture('api_entreprise_500.json')
      )
    end

    it 'raises an error' do
      expect { facility }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end

  context 'Token is unauthorized' do
    let(:token) { '' }
    let(:siret) { '41816609600069' }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, url).to_return(
        status: 401,
        body: file_fixture('api_entreprise_401.json')
      )
    end

    it 'raises an error' do
      expect { facility }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end
end
