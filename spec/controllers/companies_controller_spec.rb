# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  login_user

  describe 'GET #show' do
    let!(:api_facility) { ApiConsumption::Facility.new(siret) }
    let(:siret) { '41816609600051' }

    before do
      allow(ApiConsumption::Facility).to receive(:new).with(siret) { api_facility }
      allow(api_facility).to receive(:call)
      company_json = JSON.parse(file_fixture('api_entreprise_entreprise_request_data.json').read)
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

  describe 'GET #needs' do
    subject(:request) { get :needs, params: { siret: facility.siret } }

    let(:facility) { create :facility }
    let(:expert) { current_user.experts.first }
    let(:another_expert) { create :expert }
    # Besoin avec MER status: :quo de l'expert
    let(:quo_diagnosis) { create :diagnosis, facility: facility }
    let(:quo_need) { create :need_with_matches, diagnosis: quo_diagnosis, status: :quo }
    let!(:quo_match) { create :match, need: quo_need, expert: expert, status: :quo }
    # Besoin avec MER status: :done de l'expert
    let(:done_diagnosis) { create :diagnosis, facility: facility }
    let(:done_need) { create :need_with_matches, diagnosis: done_diagnosis, status: :done }
    let!(:done_match) { create :match, need: done_need, expert: expert, status: :done }
    # Besoin status: :done avec MER de l'expert status: :quo
    let(:done_diagnosis2) { create :diagnosis, facility: facility }
    let(:done_need2) { create :need_with_matches, diagnosis: done_diagnosis2, status: :done }
    let!(:done_match2) { create :match, need: done_need2, expert: expert, status: :quo }
    let!(:done_match3) { create :match, need: done_need2, expert: another_expert, status: :done }
    # Besoin status: :quo d'un autre expert
    let(:another_quo_diagnosis) { create :diagnosis, facility: facility }
    let(:another_quo_need) { create :need_with_matches, diagnosis: another_quo_diagnosis, status: :quo }
    let!(:another_quo_match) { create :match, expert: another_expert, need: another_quo_need, status: :quo }
    # Besoin status: :done d'un autre expert
    let(:another_done_diagnosis) { create :diagnosis, facility: facility }
    let(:another_done_need) { create :need_with_matches, diagnosis: another_done_diagnosis, status: :done }
    let!(:another_done_match) { create :match, expert: another_expert, need: another_done_need, status: :done }

    describe 'for user' do
      before { request }

      it 'content user matches only' do
        expect(assigns(:needs_in_progress)).to match_array [quo_need, done_need2]
        expect(assigns(:needs_done)).to match_array [done_need]
      end
    end

    describe 'for admin' do
      before do
        current_user.update is_admin: true
        request
      end

      it 'content all needs' do
        expect(assigns(:needs_in_progress)).to match_array [quo_need, another_quo_need]
        expect(assigns(:needs_done)).to match_array [done_need, another_done_need, done_need2]
      end
    end
  end
end
