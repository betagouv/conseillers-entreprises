# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  login_user

  describe 'GET #index' do
    it 'returns http success' do
      allow(Search).to receive(:last_queries_of_user).with(current_user)
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #search' do
    let(:siret) { '12345678901234' }

    it 'redirects to the show page' do
      allow(UseCases::SearchCompany).to receive(:with_siret_and_save).with(siret: siret, user: current_user)
      post :search, params: { company: { siret: siret } }
      is_expected.to redirect_to company_path(siret)
    end
  end

  describe 'GET #show' do
    let(:siret) { '12345678901234' }

    it do
      api_json = { 'entreprise' => { 'nom_commercial' => 'Random name' } }
      allow(UseCases::SearchCompany).to receive(:with_siret).with(siret) { api_json }
      get :show, params: { siret: siret }
      expect(response).to have_http_status(:success)
    end
  end
end
