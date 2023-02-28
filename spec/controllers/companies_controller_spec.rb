# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe CompaniesController do
  login_user

  let(:siret) { '41816609600069' }
  let(:siren) { siret[0,9] }
  let(:suffix_url) { "context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013" }
  let(:etablissement_url) { "https://entreprise.api.gouv.fr/v3/insee/sirene/etablissements/#{siret}?#{suffix_url}" }
  let(:entreprise_url) { "https://entreprise.api.gouv.fr/v3/insee/sirene/unites_legales/#{siren}?#{suffix_url}" }
  let(:effectif_etablissement_url) { "https://entreprise.api.gouv.fr/v2/effectifs_mensuels_acoss_covid/2022/08/etablissement/#{siret}?#{suffix_url}" }
  let(:effectif_entreprise_url) { "https://entreprise.api.gouv.fr/v2/effectifs_mensuels_acoss_covid/2022/08/entreprise/#{siren}?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=#{token}" }
  let(:opco_url) { "https://www.cfadock.fr/api/opcos?siret=#{siret}" }
  let(:rcs_url) { "https://entreprise.api.gouv.fr/v3/infogreffe/rcs/unites_legales/#{siren}/extrait_kbis?#{suffix_url}" }
  let(:rm_url) { "https://entreprise.api.gouv.fr/v3/cma_france/rnm/unites_legales/#{siren}?#{suffix_url}" }
  let(:token) { '1234' }

  describe 'GET #show_with_siret' do
    context 'when the api is up' do
      before do
        ENV['API_ENTREPRISE_TOKEN'] = token
        stub_request(:get, etablissement_url).to_return(body: file_fixture('api_entreprise_etablissement.json'))
        stub_request(:get, entreprise_url).to_return(body: file_fixture('api_entreprise_etablissement.json'))
        stub_request(:get, effectif_etablissement_url).to_return(body: file_fixture('api_entreprise_effectifs_etablissement.json'))
        stub_request(:get, effectif_entreprise_url).to_return(body: file_fixture('api_entreprise_effectifs_entreprise.json'))
        stub_request(:get, opco_url).to_return(body: file_fixture('api_cfadock_get_opco.json'))
        stub_request(:get, rcs_url).to_return(body: file_fixture('api_entreprise_rcs.json'))
        stub_request(:get, rm_url).to_return(body: file_fixture('api_entreprise_rm.json'))
      end

      it do
        get :show_with_siret, params: { siret: siret }
        expect(response).to be_successful
      end
    end

    context 'when the api is down' do
      before do
        body = file_fixture('api_entreprise_500.json').read
        ENV['API_ENTREPRISE_TOKEN'] = token
        stub_request(:get, etablissement_url).to_return(status: 502, body: body)
      end

      it do
        get :show_with_siret, params: { siret: siret }
        expect(response).to redirect_to search_companies_url
      end
    end
  end

  describe 'GET #show' do
    let(:facility) { create :facility, siret: siret }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, etablissement_url).to_return(body: file_fixture('api_entreprise_etablissement.json'))
      stub_request(:get, entreprise_url).to_return(body: file_fixture('api_entreprise_etablissement.json'))
      stub_request(:get, effectif_etablissement_url).to_return(body: file_fixture('api_entreprise_effectifs_etablissement.json'))
      stub_request(:get, effectif_entreprise_url).to_return(body: file_fixture('api_entreprise_effectifs_entreprise.json'))
      stub_request(:get, opco_url).to_return(body: file_fixture('api_cfadock_get_opco.json'))
      stub_request(:get, rcs_url).to_return(body: file_fixture('api_entreprise_rcs.json'))
      stub_request(:get, rm_url).to_return(body: file_fixture('api_entreprise_rm.json'))
    end

    it do
      get :show, params: { id: facility.id }
      expect(response).to be_successful
    end
  end

  describe 'GET #search' do
    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      stub_request(:get, entreprise_url).to_return(body: file_fixture('api_entreprise_etablissement.json'))
    end

    it do
      get :search, params: { query: siren }
      expect(response).to be_successful
    end
  end

  describe 'GET #needs' do
    subject(:request) { get :needs, params: { id: facility.id } }

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
        current_user.user_rights.create(category: 'admin')
        request
      end

      it 'content all needs' do
        expect(assigns(:needs_in_progress)).to match_array [quo_need, another_quo_need]
        expect(assigns(:needs_done)).to match_array [done_need, another_done_need, done_need2]
      end
    end
  end
end
