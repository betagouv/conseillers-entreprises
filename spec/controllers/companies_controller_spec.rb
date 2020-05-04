# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  login_user

  describe 'GET #show' do
    siret = '41816609600051'

    before do
      allow(UseCases::SearchFacility).to receive(:with_siret).with(siret)
      company_json = JSON.parse(file_fixture('api_entreprise_get_entreprise.json').read)
      entreprise_wrapper = ApiEntreprise::EntrepriseWrapper.new(company_json)
      allow(UseCases::SearchCompany).to receive(:with_siret).with(siret) { entreprise_wrapper }
    end

    it do
      get :show, params: { siret: siret }
      expect(response).to be_successful
    end
  end

  describe 'GET #searchmatch_spec.rb' do
    it do
      get :search
      expect(response).to be_successful
    end
  end
end
