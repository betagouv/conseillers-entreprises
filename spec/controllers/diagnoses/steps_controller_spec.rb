# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Diagnoses::StepsController, type: :controller do
  login_user

  let(:diagnosis) { create :diagnosis, advisor: advisor }
  let(:advisor) { current_user }

  describe 'GET #needs' do
    subject(:request) { get :needs, params: { id: diagnosis.id } }

    context 'diagnosis' do
      it('returns http success') { expect(response).to be_successful }
    end
  end

  describe 'GET #visit' do
    subject(:request) { get :visit, params: { id: diagnosis.id } }

    context 'diagnosis step < last' do
      it('returns http success') { expect(response).to be_successful }
    end
  end

  describe 'POST #update_visit' do
    let(:diagnosis) { create :diagnosis, advisor: advisor, visitee: nil }
    let(:locality) { diagnosis.facility.readable_locality }
    let(:advisor) { current_user }

    describe 'with the original address' do
      let(:params) { { diagnosis: { visitee_attributes: { full_name: "Edith Piaf", role: "directrice", email: "edith@piaf.fr", phone_number: "0606060606" }, happened_on: "27/01/2020" }, id: diagnosis.id } }

      it 'create a visitee for diagnosis' do
        post :update_visit, params: params
        diagnosis.reload
        expect(diagnosis.visitee.full_name).to eq("Edith Piaf")
        expect(diagnosis.facility.readable_locality).to eq(locality)
      end
    end

    describe 'with custom address' do
      let(:params) { { diagnosis: { visitee_attributes: { full_name: "Edith Piaf", role: "directrice", email: "edith@piaf.fr", phone_number: "0606060606" }, happened_on: "27/01/2020" }, id: diagnosis.id, insee_code: '78586' } }
      let(:url) { "https://geo.api.gouv.fr/communes/78586?fields=nom,codesPostaux" }
      let(:headers) { { 'Connection': 'close', 'Host': 'geo.api.gouv.fr', 'User-Agent': /http\.rb.*/ } }

      before do
        stub_request(:get, url).with(headers: headers).to_return(
          status: 200, headers: {},
          body: File.read(Rails.root.join('spec', 'fixtures', 'geo_api_communes_78586.json'))
        )
      end

      it 'create a visitee for diagnosis and change locality' do
        post :update_visit, params: params
        diagnosis.reload
        expect(diagnosis.visitee.full_name).to eq("Edith Piaf")
        expect(diagnosis.facility.readable_locality).to eq('78500 Sartrouville')
      end
    end
  end

  describe 'GET #matches' do
    subject(:request) { get :matches, params: { id: diagnosis.id } }

    context 'diagnosis' do
      it('returns http success') { expect(response).to be_successful }
    end
  end

  describe 'POST #update_matches' do
    let(:expert_subject) { create(:expert_subject) }
    let!(:need) { create(:need, diagnosis: diagnosis) }

    before do
      post :update_matches, params: { id: diagnosis.id, matches: { need.id => { expert_subject.id => '1' } } }
    end

    context 'match_and_notify! succeeds' do
      let(:result) { true }

      it('redirects to the besoins page') { expect(response).to redirect_to need_path(diagnosis) }
    end

    context 'match_and_notify! fails' do
      let(:result) { false }

      it('fails') { expect(response).not_to be_successful }
    end
  end
end
