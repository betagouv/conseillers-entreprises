# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe SearchFacility::All do
  let(:search_params) { { query: "#{query}" } }

  describe 'from_full_text_or_siren' do
    let(:data) { described_class.new(search_params).from_full_text_or_siren.as_json['items'] }
    let(:token) { '1234' }

    context 'from_siren' do
      let(:suffix_url) { "context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013" }
      let(:entreprise_url) { "https://entreprise.api.gouv.fr/v3/insee/sirene/unites_legales/#{query}?#{suffix_url}" }
      let(:etablissement_url) { "https://entreprise.api.gouv.fr/v3/insee/sirene/etablissements/#{siret_siege}?#{suffix_url}" }

      let(:query) { '418166096' }
      let(:siret_siege) { '41816609600069' }

      before do
        ENV['API_ENTREPRISE_TOKEN'] = token
        stub_request(:get, entreprise_url).to_return(
          body: file_fixture('api_entreprise_entreprise.json')
        )
        stub_request(:get, etablissement_url).to_return(
          body: file_fixture('api_entreprise_etablissement.json')
        )
      end

      it 'displays correct proposition' do
        expect(data.size).to eq(1)
        expect(data[0]["siret"]).to eq("41816609600069")
        expect(data[0]["siren"]).to eq("418166096")
        expect(data[0]["nom"]).to eq("OCTO-TECHNOLOGY")
        expect(data[0]["activite"]).to eq("Conseil en systèmes et logiciels informatiques")
        expect(data[0]["lieu"]).to eq("75002 PARIS 2")
        expect(data[0]["code_region"]).to eq("11")
        expect(data[0]["nombre_etablissements_ouverts"]).to eq(1)
      end
    end

    context 'from_siret' do
      let(:base_url) { 'https://entreprise.api.gouv.fr/v3/etablissements' }
      let(:suffix_url) { "context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013" }
      let(:etablissement_url) { "https://entreprise.api.gouv.fr/v3/insee/sirene/etablissements/#{query}?#{suffix_url}" }
      let(:entreprise_url) { "https://entreprise.api.gouv.fr/v3/insee/sirene/unites_legales/#{query[0..8]}?#{suffix_url}" }
      let(:query) { '41816609600069' }

      before do
        ENV['API_ENTREPRISE_TOKEN'] = token
        stub_request(:get, etablissement_url).to_return(
          body: file_fixture('api_entreprise_etablissement.json')
        )
        stub_request(:get, entreprise_url).to_return(
          body: file_fixture('api_entreprise_entreprise.json')
        )
      end

      it 'displays correct proposition' do
        expect(data.size).to eq(1)
        expect(data[0]["siret"]).to eq("41816609600069")
        expect(data[0]["siren"]).to eq("418166096")
        expect(data[0]["nom"]).to eq("OCTO-TECHNOLOGY")
        expect(data[0]["activite"]).to eq("Conseil en systèmes et logiciels informatiques")
        expect(data[0]["lieu"]).to eq("75002 PARIS 2")
        expect(data[0]["code_region"]).to eq("11")
        expect(data[0]["nombre_etablissements_ouverts"]).to eq(1)
      end
    end
  end
end
