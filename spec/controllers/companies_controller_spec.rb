# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  login_user

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #search' do
    subject(:request) { post :search, params: { company: { siret: siret } } }

    let(:siret) { '12345678901234' }
    let(:company_name) { 'Company Name' }

    before do
      api_json = { 'entreprise' => { 'nom_commercial' => company_name } }
      allow(ApiEntrepriseService).to receive(:fetch_company_with_siret).with(siret) { api_json }
      request
    end

    it('returns http success') { expect(response).to have_http_status(:success) }

    it 'creates a Search entry' do
      expect(Search.last.user).to eq current_user
      expect(Search.last.query).to eq siret
      expect(Search.last.label).to eq company_name
    end
  end

  describe 'GET #show' do
    let(:company) { create :company }

    it 'returns http success' do
      get :show, params: { id: company.id }
      expect(response).to have_http_status(:success)
    end
  end
end
