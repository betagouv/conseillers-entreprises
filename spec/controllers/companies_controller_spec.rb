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
      api_json = { 'entreprise' => { 'nom_commercial' => company_name } }
      allow(QwantApiService).to receive(:results_for_query).with(company_name)
      get :show, params: { id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end
end
