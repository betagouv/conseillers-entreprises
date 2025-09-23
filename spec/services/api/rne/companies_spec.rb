require 'rails_helper'
require 'api_helper'

RSpec.describe Api::Rne::Companies do
  let(:api) { described_class::Base.new(siren).call }
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
      expect(api[:errors]).to eq(standard_api_errors: { "api-rne-companies-base" => "Impossible de trouver la ressource demandée" })
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
      expect(api[:errors]).to eq({ :unreachable_apis => { "api-rne-companies-base" => "Internal Server Error" } })
    end
  end
end
