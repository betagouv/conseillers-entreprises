# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe Api::RechercheEntreprises::Search::Siret::Base do
  let(:api) { described_class.new(query).call }
  let(:url) { "https://recherche-entreprises.api.gouv.fr/search?mtm_campaign=conseillers-entreprises&q=#{query}" }

  context 'Query reconnue' do
    let(:query) { '41816609600069' }

    before do
      stub_request(:get, url).to_return(
        body: file_fixture('api_recherche_entreprises_search_siret.json')
      )
    end

    it 'returns company forme_exercice' do
      expect(api[:liste_idcc]).to eq(["1486"])
    end
  end

  context 'Query vide' do
    let(:query) { '' }

    before do
      stub_request(:get, url).to_return(
        status: 400,
        body: ({ erreur: "Veuillez indiquer au moins un paramètre de recherche." }.to_json)
      )
    end

    it 'returns an error' do
      expect { api }.to raise_error "Veuillez indiquer au moins un paramètre de recherche."
    end
  end
end
