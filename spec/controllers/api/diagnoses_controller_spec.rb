# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DiagnosesController, type: :controller do
  login_user

  let(:content) { Faker::Lorem.paragraph }
  let(:diagnosis) { create :diagnosis, content: content }

  describe 'GET #show' do
    it('returns http success') do
      get :show, format: :json, params: { id: diagnosis.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    context 'save worked' do
      it 'redirects to the show page' do
        siret = '12345678901234'
        facility = create :facility, siret: siret
        allow(UseCases::SearchFacility).to receive(:with_siret_and_save).with(siret) { facility }

        post :create, format: :json, params: { siret: siret }

        expect(response).to have_http_status(:created)
        expect(response.headers['Location']).to eq api_diagnosis_url(Diagnosis.last)
      end
    end

    context 'saved failed' do
      it 'does not redirect' do
        allow(UseCases::SearchFacility).to receive(:with_siret_and_save)

        post :create, format: :json, params: {}

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'PATCH #update' do
    subject(:request) do
      patch :update, format: :json, params: params
    end

    let(:new_content) { 'Lorem fake stuff content' }
    let(:new_step) { 4 }
    let(:params) { { id: diagnosis.id, diagnosis: { content: new_content, step: new_step } } }

    context 'when parameters are OK' do
      before { request }

      it('returns http success') { expect(response).to have_http_status(:success) }
      it('updates the diagnosis s content') { expect(diagnosis.reload.content).to eq(new_content) }
      it('updates the diagnosis s step') { expect(diagnosis.reload.step).to eq(new_step) }
    end

    context 'when update fails' do
      before do
        allow(UseCases::UpdateDiagnosis).to receive(:clean_update_params).and_raise(StandardError)
        request
      end

      it('returns http bad request') { expect(response).to have_http_status(:bad_request) }
      it('does not update the diagnosis s content') { expect(diagnosis.reload.content).to eq(content) }
      it('does not update the diagnosis s step') { expect(diagnosis.reload.step).to eq(1) }
    end
  end
end
