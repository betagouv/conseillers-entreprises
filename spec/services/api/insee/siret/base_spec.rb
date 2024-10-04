# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe Api::Insee::Siret::Base do
  let(:api) { described_class.new(siret).call }
  let(:url) { "https://api.insee.fr/entreprises/sirene/V3.11/siret/?q=siret:#{siret}" }

  context 'SIRET reconnu' do
    let(:siret) { '41816609600069' }

    before do
      authorize_insee_token
      stub_request(:get, url).to_return(
        body: file_fixture('api_insee_siret.json')
      )
    end

    it 'returns correct data' do
      expect(api[:entreprise]['denominationUniteLegale']).to eq('OCTO-TECHNOLOGY')
    end
  end

  context 'Siret non trouvable' do
    let(:siret) { '89448692700011' }

    before do
      authorize_insee_token
      stub_request(:get, url).to_return(
        body: file_fixture('api_insee_siret_400.json'),
        status: 404
      )
    end

    it 'returns an error' do
      expect { api }.to raise_error(Api::ApiError, "Nous n’avons pas pu identifier votre entité. Peut-être est-elle non diffusible ?")
    end
  end

  context 'Erreur 500' do
    let(:siret) { '89448692700011' }

    before do
      authorize_insee_token
      stub_request(:get, url).to_return(
        body: { erreur: 'xste' }.to_json,
        status: 500
      )
    end

    it 'returns a technical error' do
      expect { api }.to raise_error(Api::UnavailableApiError, "Nous n’avons pas pu récupérer les données entreprises auprès de nos partenaires. Notre équipe technique en a été informée, veuillez réessayer ultérieurement.")
    end
  end
end
