# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe ApiRne::Companies::Base do
  let(:api_company) { described_class.new(siren).call }
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
      expect(api_company['forme_exercice']).to eq('COMMERCIALE')
    end
  end

  context 'SIREN non reconnu' do
    let(:siren) { '211703806' }

    before do
      authorize_rne_token
      stub_request(:get, url).to_return(
        status: 500, body: file_fixture('api_rne_companies_404.json')
      )
    end

    it 'returns an error' do
      expect(api_company['rne']).to eq("error" => "Impossible de trouver la ressource demandée")
    end
  end
end
