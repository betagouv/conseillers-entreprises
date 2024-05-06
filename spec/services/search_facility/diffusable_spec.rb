# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe SearchFacility::Diffusable do
  let(:search_params) { { query: "#{query}" } }

  describe 'from_full_text_or_siren' do
    let(:data) { described_class.new(search_params).from_full_text_or_siren.as_json['items'] }

    context 'from_siren' do
      let(:api_url) { "https://api.insee.fr/entreprises/sirene/V3.11/siret/?q=siren:#{query}" }
      let(:query) { '418166096' }

      before do
        authorize_insee_token
        stub_request(:get, api_url).to_return(
          body: file_fixture('api_insee_sirets_by_siren_many.json')
        )
      end

      it 'displays correct proposition' do
        expect(data.size).to eq(2)
        expect(data[0]["siret"]).to eq("41816609600069")
        expect(data[0]["siren"]).to eq("418166096")
        expect(data[0]["nom"]).to eq("Octo Technology")
        expect(data[0]["activite"]).to eq("Programmation, conseil et autres activités informatiques")
        expect(data[0]["lieu"]).to eq("75002 PARIS 2")
        expect(data[0]["code_region"]).to eq("11")
        expect(data[0]["nombre_etablissements_ouverts"]).to eq(2)
      end
    end

    context 'from_siret' do
      let(:api_url) { "https://api.insee.fr/entreprises/sirene/V3.11/siret/?q=siret:#{query}" }
      let(:query) { '41816609600069' }

      before do
        authorize_insee_token
        stub_request(:get, api_url).to_return(
          body: file_fixture('api_insee_siret.json')
        )
      end

      it 'displays correct proposition' do
        expect(data.size).to eq(1)
        expect(data[0]["siret"]).to eq("41816609600069")
        expect(data[0]["siren"]).to eq("418166096")
        expect(data[0]["nom"]).to eq("Octo Technology")
        expect(data[0]["activite"]).to eq("Programmation, conseil et autres activités informatiques")
        expect(data[0]["lieu"]).to eq("75002 PARIS 2")
        expect(data[0]["code_region"]).to eq("11")
        expect(data[0]["nombre_etablissements_ouverts"]).to eq(1)
      end
    end

    context 'from_fulltext' do
      let(:api_url) { "https://recherche-entreprises.api.gouv.fr/search?mtm_campaign=conseillers-entreprises&q=#{query}" }
      let(:query) { 'octo technology' }

      before do
        stub_request(:get, api_url).to_return(
          body: file_fixture('api_recherche_entreprises_search.json')
        )
      end

      it 'displays correct proposition' do
        expect(data.size).to eq(3)
        expect(data[0]["siret"]).to eq("41816609600069")
        expect(data[0]["siren"]).to eq("418166096")
        expect(data[0]["nom"]).to eq("Octo Technology")
        expect(data[0]["activite"]).to eq("Programmation, conseil et autres activités informatiques")
        expect(data[0]["lieu"]).to eq("75002 PARIS 2")
        expect(data[0]["code_region"]).to eq("11")
        expect(data[0]["nombre_etablissements_ouverts"]).to eq(2)
      end
    end
  end
end
