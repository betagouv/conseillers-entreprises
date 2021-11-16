# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchEtablissement do
  let(:search_params) { { query: "#{query}", non_diffusables: "false" } }
  let(:data) { described_class.call(search_params).as_json }

  context 'fulltext search' do
    let(:api_url) { "https://entreprise.data.gouv.fr/api/sirene/v1/full_text/#{query}" }
    let(:query) { 'octo techno' }

    before do
      stub_request(:get, api_url).to_return(
        body: file_fixture('entreprise_data_gouv_full_text.json')
      )
    end

    it 'displays correct proposition' do
      expect(data[0]["siret"]).to eq("41816609600069")
      expect(data[0]["nom"]).to eq("OCTO-TECHNOLOGY")
      expect(data[0]["activite"]).to eq("Conseil en systèmes et logiciels informatiques")
      expect(data[0]["code_region"]).to eq("11")
    end
  end

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
      expect(data[0]["nom"]).to eq("OCTO-TECHNOLOGY")
      expect(data[0]["activite"]).to eq("Conseil en systèmes et logiciels informatiques")
      expect(data[0]["code_region"]).to eq("11")
    end
  end
end
