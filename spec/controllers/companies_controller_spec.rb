# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  login_user

  describe 'POST #search_by_siret' do
    subject(:request) { post :search_by_siret, params: { siret: siret }, format: :js }

    let(:facility) { build :facility }
    let(:siret) { facility.siret }

    it 'returns http success' do
      api_json = JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json'))
      allow(UseCases::SearchCompany).to receive(:with_siret).with(siret) { api_json }
      request
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #search_by_name' do
    subject(:request) { post :search_by_name, params: { company: search_company_params }, format: :js }

    let(:search_company_params) { { name: 'Octo', county: '75' } }

    it 'returns http success' do
      allow(FirmapiService).to receive(:search_companies)
      request
      expect(FirmapiService).to have_received(:search_companies).with(search_company_params)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it do
      visit = create :visit, :with_facility
      api_json = { 'etablissement' => { 'nom_commercial' => visit.company_name } }
      allow(UseCases::SearchFacility).to receive(:with_siret).with(visit.facility.siret) { api_json }
      allow(QwantApiService).to receive(:results_for_query).with(visit.company_name)
      get :show, params: { id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end
end
