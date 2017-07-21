# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::FacilitiesController, type: :controller do
  login_user

  describe 'POST #search_by_siret' do
    let(:facility) { build :facility }
    let(:siret) { facility.siret }

    before do
      facility_api_json = JSON.parse(File.read('./spec/fixtures/api_entreprise_get_etablissement.json'))
      company_api_json = JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json'))
      allow(UseCases::SearchFacility).to receive(:with_siret).with(siret) { facility_api_json }
      allow(UseCases::SearchCompany).to receive(:with_siret).with(siret) { company_api_json }
    end

    it 'returns http success' do
      post :search_by_siret, params: { siret: siret }, format: :js

      expect(response).to have_http_status(:success)
      expect(response.body).to eq({ company_name: 'Octo Technology', facility_location: '75008 Paris 8' }.to_json)
    end
  end
end
