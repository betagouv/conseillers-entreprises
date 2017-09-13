# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::CompaniesController, type: :controller do
  login_user

  describe 'POST #search_by_name' do
    subject(:search_by_name) { post :search_by_name, params: { company: { name: name, county: county } }, format: :js }

    let(:name) { 'Octo' }
    let(:county) { '75' }
    let(:companies_array) { [{ 'siren' => '12456789' }] }

    it 'returns http success' do
      allow(UseCases::SearchCompany).to receive(:with_name_and_county) { companies_array }

      search_by_name

      expect(UseCases::SearchCompany).to have_received(:with_name_and_county).with(name, county)
      expect(response).to have_http_status(:success)
      expect(response.body).to eq({ companies: companies_array }.to_json)
    end
  end
end
