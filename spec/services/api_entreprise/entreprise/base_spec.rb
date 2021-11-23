# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiEntreprise::Entreprise::Base do
  let(:api_company) { described_class.new(siren).call }
  let(:base_url) { 'https://entreprise.api.gouv.fr/v2/entreprises' }

  before { Rails.cache.clear }

  context 'SIREN number exists' do
    let(:token) { '1234' }
    let(:siren) { '418166096' }
    let(:url) { "#{base_url}/418166096?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, url).to_return(
        body: file_fixture('api_entreprise_get_entreprise.json')
      )
    end

    it 'returns an entreprise with good fields' do
      expect(api_company['entreprise']['siren']).to be_present
      expect(api_company['entreprise']['raison_sociale']).to be_present
    end

    it 'has an etablissement_siege with the right fields' do
      expect(api_company['etablissement_siege']['siret']).to be_present
    end

    it 'doesnt set rcs subscription' do
      expect(api_company['entreprise']['inscrit_rcs']).to eq nil
    end

    it 'doesnt set rm subscription' do
      expect(api_company['entreprise']['inscrit_rm']).to eq nil
    end
  end

  context 'SIREN is missing' do
    let(:token) { '1234' }
    let(:siren) { '' }
    let(:url) { "#{base_url}/?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, url).to_return(
        status: 500, body: '{}'
      )
    end

    it 'raises an error' do
      expect { api_company }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end

  context 'SIREN does not exist' do
    let(:token) { '1234' }
    let(:siren) { '' }
    let(:url) { "#{base_url}/?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, url).to_return(
        status: 500,
        body: file_fixture('api_entreprise_get_entreprise_422.json')
      )
    end

    it 'raises an error' do
      expect { api_company }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end

  context 'Token is unauthorized' do
    let(:token) { '' }
    let(:siren) { '123456789' }
    let(:url) { "#{base_url}/123456789?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=" }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, url).to_return(
        status: 401,
        body: file_fixture('api_entreprise_401.json')
      )
    end

    it 'raises an error' do
      expect { api_company }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end
end
