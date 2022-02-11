# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchEtablissement do
  let(:search_params) { { query: "#{query}", non_diffusables: "false" } }
  let(:data) { described_class.call(search_params).as_json }

  context 'siret search' do
    let(:token) { '1234' }
    let(:api_url) { "https://entreprise.api.gouv.fr/v2/entreprises/#{query}?context=PlaceDesEntreprises&non_diffusables=false&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }
    let(:query) { '418166096' }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, api_url).to_return(
        body: file_fixture('api_entreprise_get_entreprise.json')
      )
    end

    it 'displays correct proposition' do
      expect(data[0]["siret"]).to eq("41816609600051")
      expect(data[0]["nom"]).to eq("Octo Technology")
      expect(data[0]["activite"]).to eq("Conseil en systèmes et logiciels informatiques")
      expect(data[0]["code_region"]).to eq("11")
    end
  end
end
