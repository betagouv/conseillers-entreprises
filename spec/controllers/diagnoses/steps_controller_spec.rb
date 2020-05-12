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
      let(:params) do
        {
          id: diagnosis.id,
          diagnosis: {
            happened_on: "27/01/2020",
            visitee_attributes: {
              full_name: "Edith Piaf", role: "directrice", email: "edith@piaf.fr", phone_number: "0606060606"
            }
          }
        }
      end

      it 'create a visitee for diagnosis' do
        post :update_visit, params: params
        diagnosis.reload
        expect(diagnosis.visitee.full_name).to eq("Edith Piaf")
        expect(diagnosis.facility.readable_locality).to eq(locality)
      end
    end

    describe 'with custom address' do
      let(:params) do
        {
          id: diagnosis.id,
          diagnosis: {
            happened_on: "27/01/2020",
            visitee_attributes: {
              full_name: "Edith Piaf", role: "directrice", email: "edith@piaf.fr", phone_number: "0606060606",
            },
            facility_attributes: {
              id: diagnosis.facility_id,
              insee_code: '78586'
            }
          }
        }
      end
      let(:url) { "https://geo.api.gouv.fr/communes/78586?fields=nom,codesPostaux" }

      before do
        stub_request(:get, url).to_return(
          body: file_fixture('geo_api_communes_78586.json')
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
    let(:need) { create(:need, diagnosis: diagnosis) }

    let(:params) do
      {
        id: diagnosis.id,
        diagnosis: {
          needs_attributes: [
            {
              id: need.id,
              matches_attributes: [
                {
                  _destroy: selected ? '0' : '1',
                  subject_id: expert_subject.subject.id,
                  expert_id: expert_subject.expert.id,
                }
              ]
            }
          ]
        }
      }
    end

    context 'one match selected' do
      let(:selected) { true }

      it('redirects to the besoins page') {
        post :update_matches, params: params

        diagnosis.reload
        expect(diagnosis.matches.count).to eq 1
        expect(response).to redirect_to need_path(diagnosis)
      }
    end

    context 'no match selected' do
      let(:selected) { false }

      it('redirects to the besoins page') {
        post :update_matches, params: params

        diagnosis.reload
        expect(diagnosis.matches.count).to eq 0
        expect(response).to redirect_to matches_diagnosis_path(diagnosis)
      }
    end
  end
end
