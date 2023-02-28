# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiEntreprise::Entreprise::Base do
  let(:api_company) { described_class.new(siren).call[:entreprise] }
  let(:suffix_url) { "context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013" }
  let(:url) { "https://entreprise.api.gouv.fr/v3/insee/sirene/unites_legales/#{siren}?#{suffix_url}" }

  context 'SIREN number exists' do
    let(:token) { '1234' }
    let(:siren) { '418166096' }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, url).to_return(
        body: file_fixture('api_entreprise_entreprise.json')
      )
    end

    it 'returns an entreprise with good fields' do
      expect(api_company['siren']).to be_present
      expect(api_company["personne_morale_attributs"]['raison_sociale']).to be_present
    end

    it 'doesnt set rcs subscription' do
      expect(api_company['inscrit_rcs']).to be_nil
    end

    it 'doesnt set rm subscription' do
      expect(api_company['inscrit_rm']).to be_nil
    end
  end

  context 'SIREN is missing' do
    let(:token) { '1234' }
    let(:siren) { '' }

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
    let(:siren) { '123456789' }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, url).to_return(
        status: 500,
        body: file_fixture('api_entreprise_500.json')
      )
    end

    it 'raises an error' do
      expect { api_company }.to raise_error ApiEntreprise::ApiEntrepriseError
    end
  end

  context 'Token is unauthorized' do
    let(:token) { '' }
    let(:siren) { '418166096' }

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
