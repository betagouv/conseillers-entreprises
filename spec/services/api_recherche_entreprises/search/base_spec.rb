# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe ApiRechercheEntreprises::Search::Base do
  let(:api) { described_class.new(query).call }
  let(:url) { "https://recherche-entreprises.api.gouv.fr/search?mtm_campaign=conseillers-entreprises&q=#{query}" }

  context 'Query reconnue' do
    let(:query) { 'octo technology' }

    before do
      stub_request(:get, url).to_return(
        body: file_fixture('api_recherche_entreprises_search.json')
      )
    end

    it 'returns company forme_exercice' do
      expect(api[0][:entreprise]["nom_raison_sociale"]).to eq("OCTO-TECHNOLOGY")
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

  context 'Rate limit' do
    let(:query) { 'lalala' }

    before do
      stub_request(:get, url).to_return(
        status: 429,
        body: ({ erreur: "Trop de requêtes." }.to_json)
      )
    end

    it 'raises an error' do
      expect { api }.to raise_error "Nous n’avons pas pu récupérer les détails de votre entité auprès de nos partenaires"
    end
  end

  context 'Error 500' do
    let(:query) { 'lalala' }

    before do
      stub_request(:get, url).to_return(
        status: 500,
        body: ({ erreur: "Connection refused" }.to_json)
      )
    end

    it 'raises an error' do
      expect { api }.to raise_error "Nous n’avons pas pu récupérer les détails de votre entité auprès de nos partenaires"
    end
  end

end
