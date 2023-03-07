# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiConsumption::Models::FacilityAutocomplete::ApiEntreprise do
  describe 'new' do
    let!(:api_model) { described_class.new(params) }

    context 'without params' do
      let(:params) { nil }

      it 'fails silently' do
        expect{ api_model }.not_to raise_error
      end
    end

    context 'with params' do
      let(:params) do
        {
          "entreprise" => JSON.parse(file_fixture('api_entreprise_entreprise.json').read)["data"],
          "etablissement" => JSON.parse(file_fixture('api_entreprise_etablissement.json').read)["data"]
        }
      end

      it 'returns the right fields' do
        expect(api_model.as_json).to include({
          'siret' => "41816609600069",
          'siren' => "418166096",
          'nom' => "OCTO-TECHNOLOGY",
          'activite' => "Conseil en systèmes et logiciels informatiques",
          'lieu' => "75002",
          'code_region' => "11",
        })
      end
    end
  end
end
