# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe Api::Insee::Siret do
  let(:api) { described_class::Base.new(siret).call }
  let(:url) { "https://api.insee.fr/api-sirene/3.11/siret/#{siret}" }

  ENV['SIRENE_API_KEY'] = 'api_key'

  context 'SIRET reconnu' do
    let(:siret) { '41816609600069' }

    before do
      stub_request(:get, url)
        .with(headers: { 'X-INSEE-Api-Key-Integration' => 'api_key' })
        .to_return(body: file_fixture('api_insee_siret.json'))
    end

    it 'returns correct data' do
      expect(api[:entreprise]['denominationUniteLegale']).to eq('OCTO-TECHNOLOGY')
    end
  end

  context 'Siret non trouvable' do
    let(:siret) { '89448692700011' }

    before do
      stub_request(:get, url)
        .with(headers: { 'X-INSEE-Api-Key-Integration' => 'api_key' })
        .to_return(
          body: file_fixture('api_insee_siret_400.json'),
          status: 404
        )
    end

    it 'returns an error' do
      expect { api }.to raise_error(Api::TechnicalError, "Erreur de syntaxe dans le paramètre q=liyuyv")
    end
  end

  context 'Erreur 500' do
    let(:siret) { '89448692700011' }

    before do
      stub_request(:get, url)
        .with(headers: { 'X-INSEE-Api-Key-Integration' => 'api_key' })
        .to_return(
          body: { erreur: 'xste' }.to_json,
          status: 500
        )
    end

    it 'returns a technical error' do
      expect { api }.to raise_error(Api::TechnicalError, "Internal Server Error")
    end
  end
end
