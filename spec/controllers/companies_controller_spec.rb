# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  login_user

  let(:visit) { create :visit }

  describe 'POST #search_by_siret' do
    subject(:request) { post :search_by_siret, params: { siret: visit.company.siren }, format: :js }

    let(:company) { create :company }

    it 'returns http success' do
      visit.update company: company
      api_json = JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json'))
      allow(UseCases::SearchCompany).to receive(:with_siret).with(visit.company.siren) { api_json }
      request
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #search_by_name' do
    subject(:request) { post :search_by_name, params: { visit_id: visit.id, company: { name: 'Octo', county: 75 } }, format: :js }

    it 'returns http success' do
      allow(FirmapiService).to receive(:search_companies)
      request
      expect(FirmapiService).to have_received(:search_companies).with(name: 'Octo', county: '75')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    let(:company) { create :company }

    it do
      visit.update company: company
      api_json = { 'entreprise' => { 'nom_commercial' => company.name } }
      allow(UseCases::SearchCompany).to receive(:with_siret).with(visit.company.siren) { api_json }
      allow(QwantApiService).to receive(:results_for_query).with(company.name)
      get :show, params: { id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end
end
