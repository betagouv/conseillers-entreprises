# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiEntreprise::Etablissements do
  let(:facility) { described_class.new(token).fetch(siren) }

  let(:base_url) { 'https://entreprise.api.gouv.fr/v2/etablissements' }

  before { Rails.cache.clear }

  context 'SIREN number exists' do
    let(:token) { '1234' }
    let(:siren) { '12345678901234' }
    let(:url) { "#{base_url}/12345678901234?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }

    before do
      stub_request(:get, url).to_return(
        body: file_fixture('api_entreprise_get_etablissement.json')
      )
    end

    it 'has the right fields' do
      expect(facility.etablissement.siret).to be_present
    end
  end

  context 'SIREN is missing' do
    let(:token) { '1234' }
    let(:siren) { '' }
    let(:url) { "#{base_url}/?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }

    before do
      stub_request(:get, url).to_return(
        status: 500, body: '{}'
      )
    end

    it 'raises an error' do
      expect { facility }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end

  context 'SIREN does not exist' do
    let(:token) { '1234' }
    let(:siren) { '' }
    let(:url) { "#{base_url}/?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }

    before do
      stub_request(:get, url).to_return(
        status: 500,
        body: file_fixture('api_entreprise_get_entreprise.json')
      )
    end

    it 'raises an error' do
      expect { facility }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end

  context 'Token is unauthorized' do
    let(:token) { '' }
    let(:siren) { '12345678901234' }
    let(:url) { "#{base_url}/12345678901234?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=" }

    before do
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
