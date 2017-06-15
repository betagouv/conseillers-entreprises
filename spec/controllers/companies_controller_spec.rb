# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  login_user

  let(:visit) { create :visit }

  describe 'POST #search_by_name' do
    let(:request) { post :search_by_name, params: { visit_id: visit.id, company: { name: 'Octo', county: 75 } }, format: :js }

    it 'returns http success' do
      allow(FirmapiService).to receive(:search_companies)
      request
      expect(FirmapiService).to have_received(:search_companies).with(name: 'Octo', county: '75')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    let(:company_name) { 'Random name' }

    it do
      api_json = { 'entreprise' => { 'nom_commercial' => company_name } }
      allow(UseCases::SearchCompany).to receive(:with_siret).with(visit.siret) { api_json }
      allow(QwantApiService).to receive(:results_for_query).with(company_name)
      get :show, params: { id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end
end
