# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe Api::Rne::Companies::Base do
  let(:api) { described_class.new(siren).call }
  let(:url) { "https://registre-national-entreprises.inpi.fr/api/companies/#{siren}" }

  context 'SIREN reconnu' do
    let(:siren) { '418166096' }

    before do
      authorize_rne_token
      stub_request(:get, url).to_return(
        body: file_fixture('api_rne_companies.json')
      )
    end

    it 'returns company forme_exercice' do
      expect(api['forme_exercice']).to eq('COMMERCIALE')
    end
  end

  context 'SIREN non reconnu' do
    let(:siren) { '211703806' }

    before do
      authorize_rne_token
      stub_request(:get, url).to_return(
        status: 404,
        body: file_fixture('api_rne_companies_404.json')
      )
    end

    it 'returns an error' do
      expect(api['rne']).to eq("error" => "Impossible de trouver la ressource demandée")
    end
  end

  context 'Erreur 500' do
    let(:siren) { '211703806' }

    before do
      authorize_rne_token
      stub_request(:get, url).to_return(
        status: 500, body: ({ erreur: "Connection refused" }.to_json)
      )
    end

    it 'returns an error' do
      expect(api['rne']).to eq("error" => "Nous n’avons pas pu récupérer les données entreprises auprès de nos partenaires. Notre équipe technique en a été informée, veuillez réessayer ultérieurement.")
    end
  end
end
