# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Adresse::SearchMunicipality do
  let(:api) { described_class.new(query).call }
  let(:api_url) { "https://api-adresse.data.gouv.fr/search/?type=municipality&q=#{query}" }

  context 'Query reconnue' do
    let(:query) { 'matignon' }

    before do
      stub_request(:get, api_url).to_return(
        body: file_fixture('api_adresse_search_municipality.json')
      )
    end

    it 'returns insee code' do
      expect(api).to eq({ insee_code: '22143' })
    end
  end

  context 'Query non reconnue' do
    let(:query) { 'lalalalala' }

    before do
      stub_request(:get, api_url).to_return(
        status: 200,
        body: ({ "type" => "FeatureCollection",
        "version" => "draft",
        "features" => [],
        "attribution" => "BAN",
        "licence" => "ETALAB-2.0",
        "query" => "lalalalala",
        "filters" => { "type" => "municipality" },
        "limit" => 5 }
        .to_json)
      )
    end

    it 'returns nil insee code' do
      expect(api).to eq({ insee_code: nil })
    end
  end

  context 'Query vide' do
    let(:query) { '' }

    before do
      stub_request(:get, api_url).to_return(
        status: 400,
        body: ({ code: 400, message: "q must contain between 3 and 200 chars and start with a number or a letter" }.to_json)
      )
    end

    it 'returns an error' do
      expect(api).to eq({ "search_municipality" => { "error" => "q must contain between 3 and 200 chars and start with a number or a letter" } })
    end
  end

  context 'Error 500' do
    let(:query) { 'lalala' }

    before do
      stub_request(:get, api_url).to_return(
        status: 500,
        body: ({ erreur: "Connection refused" }.to_json)
      )
    end

    it 'raises an error' do
      expect(api).to eq({ "search_municipality" => { "error" => "Nous n’avons pas pu récupérer les données entreprises auprès de nos partenaires. Notre équipe technique en a été informée, veuillez réessayer ultérieurement." } })
    end
  end

end
