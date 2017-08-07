# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  login_user

  describe 'POST #search_by_siren' do
    it 'returns http success' do
      company = build :company
      siren = company.siren
      api_json = JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json'))
      allow(UseCases::SearchCompany).to receive(:with_siren).with(siren) { api_json }

      post :search_by_siren, params: { siren: siren }, format: :js

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
    siret = '44622002200227'
    company_name = 'C H D GRAND HAINAUT'

    before do
      allow(UseCases::SearchFacility).to receive(:with_siret).with(siret)
      allow(UseCases::SearchCompany).to receive(:with_siret).with(siret)
      allow(ApiEntrepriseService).to receive(:company_name).and_return(company_name)
      allow(QwantApiService).to receive(:results_for_query).with(company_name)
    end

    it do
      get :show, params: { siret: siret }
      expect(response).to have_http_status(:success)
    end
  end
end
