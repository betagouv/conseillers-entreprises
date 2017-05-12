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

    before { request }

    it('redirects to the show page') { is_expected.to redirect_to company_path(siret) }

    it 'creates a Search entry' do
      expect(Search.last.user).to eq current_user
      expect(Search.last.query).to eq siret
    end
  end

  describe 'GET #show' do
    subject(:request) { get :show, params: { siret: siret } }

    let(:siret) { '12345678901234' }

    before do
      api_json = { 'entreprise' => { 'nom_commercial' => 'Random name' } }
      allow(ApiEntrepriseService).to receive(:fetch_company_with_siret).with(siret) { api_json }
      request
    end

    it('returns http success') { expect(response).to have_http_status(:success) }
  end
end
