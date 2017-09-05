# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  login_user

  describe 'POST #search_by_name' do
    subject(:search_by_name) { post :search_by_name, params: { company: { name: name, county: county } }, format: :js }

    let(:name) { 'Octo' }
    let(:county) { '75' }

    it 'returns http success' do
      allow(UseCases::SearchCompany).to receive(:with_name_and_county)

      search_by_name

      expect(UseCases::SearchCompany).to have_received(:with_name_and_county).with(name, county)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    siret = '44622002200227'
    company_name = 'Octo Technology'

    before do
      allow(UseCases::SearchFacility).to receive(:with_siret).with(siret)
      company_json = JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json'))
      entreprise_wrapper = ApiEntreprise::EntrepriseWrapper.new(company_json)
      allow(UseCases::SearchCompany).to receive(:with_siret).with(siret) { entreprise_wrapper }
      allow(QwantApiService).to receive(:results_for_query).with(company_name)
    end

    it do
      get :show, params: { siret: siret }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create_diagnosis_from_siret' do
    context 'save worked' do
      it 'redirects to the created diagnosis step2 page' do
        siret = '12345678901234'
        facility = create :facility, siret: siret
        allow(UseCases::SearchFacility).to receive(:with_siret_and_save).with(siret) { facility }

        post :create_diagnosis_from_siret, format: :json, params: { siret: siret }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to step_2_diagnosis_path(Diagnosis.last)
      end
    end

    context 'saved failed' do
      it 'does not redirect' do
        allow(UseCases::SearchFacility).to receive(:with_siret_and_save)

        post :create_diagnosis_from_siret, format: :json, params: {}

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
