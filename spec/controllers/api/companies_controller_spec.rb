# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::CompaniesController, type: :controller do
  login_user

  describe 'POST #search_by_siret' do
    it 'returns http success' do
      facility = build :facility
      siret = facility.siret
      api_json = JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json'))
      allow(UseCases::SearchCompany).to receive(:with_siret).with(siret) { api_json }

      post :search_by_siret, params: { siret: siret }, format: :js

      expect(response).to have_http_status(:success)
    end
  end
end
