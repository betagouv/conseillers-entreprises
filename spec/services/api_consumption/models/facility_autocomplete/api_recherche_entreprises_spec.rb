# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiConsumption::Models::FacilityAutocomplete::ApiRechercheEntreprises do
  describe 'new' do
    let!(:api_model) { described_class.new(params) }

    context 'without params' do
      let(:params) { nil }

      it 'fails silently' do
        expect{ api_model }.not_to raise_error
      end
    end

    context 'with params' do
      let(:params) { JSON.parse(file_fixture('api_recherche_entreprises_entreprise_request_data.json').read) }

      it 'returns the right fields' do
        expect(api_model.as_json).to include({
          'siret' => "41816609600069",
          'siren' => "418166096",
          'nom' => "Octo Technology",
          'activite' => "Programmation, conseil et autres activités informatiques",
          'lieu' => "75002 PARIS 2",
          'code_region' => "11",
          'nombre_etablissements_ouverts' => 2,
        })
      end
    end
  end
end
