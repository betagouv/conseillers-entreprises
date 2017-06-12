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

    context 'visit exists' do
      it 'redirects to the show page' do
        create :visit, advisor: current_user, siret: siret
        allow(UseCases::SearchCompany).to receive(:with_siret_and_save).with(siret: siret, user: current_user)
        post :search, params: { company: { siret: siret } }
        is_expected.to redirect_to company_path(siret)
      end
    end

    context 'visit does not exist' do
      it 'redirects to the show page' do
        allow(UseCases::SearchCompany).to receive(:with_siret_and_save).with(siret: siret, user: current_user)
        post :search, params: { company: { siret: siret } }
        is_expected.to redirect_to new_visit_path(siret: siret)
      end
    end
  end

  describe 'GET #show' do
    let(:siret) { '12345678901234' }
    let(:company_name) { 'OCTO-TECHNOLOGY' }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = '1234'
      stub_request(
        :get,
        'https://api.apientreprise.fr/v2/entreprises/1234567890?token=1234'
      ).with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      ).to_return(
        status: 200,
        body: File.read(Rails.root.join('spec/responses/api_entreprise.json')),
        headers: {}
      )
    end

    it do
      allow(QwantApiService).to receive(:results_for_query).with(company_name)
      get :show, params: { siret: siret }
      expect(response).to have_http_status(:success)
    end
  end
end
