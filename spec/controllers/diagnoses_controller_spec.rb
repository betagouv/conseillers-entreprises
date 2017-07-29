# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosesController, type: :controller do
  login_user

  let(:diagnosis) { create :diagnosis }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #step1' do
    it 'returns http success' do
      get :step1
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #step2' do
    it 'returns http success' do
      get :step2, params: { id: diagnosis.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #step3' do
    it 'returns http success' do
      get :step3, params: { id: diagnosis.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #step4' do
    it 'returns http success' do
      get :step4, params: { id: diagnosis.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #notify_experts' do
    let(:assistances_experts) do
      { '12' => '1', '21' => '0', '31' => '0', '42' => '1', '43' => '1', '72' => '1', '90' => '0' }
    end

    before do
      allow(ExpertMailersService).to receive(:send_assistances_email)

      post :notify_experts, params: {
        id: diagnosis.id,
        assistances_experts: assistances_experts
      }
    end

    it('redirects to') { expect(response).to redirect_to step_5_diagnosis_path(diagnosis) }

    it 'sends emails' do
      expect(ExpertMailersService).to have_received(:send_assistances_email).with(
        advisor: current_user,
        diagnosis: diagnosis,
        assistances_experts_hash: assistances_experts
      )
    end
  end

  describe 'GET #step5' do
    it 'returns http success' do
      get :step5, params: { id: diagnosis.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'former page' do
    describe 'GET #show' do
      it 'returns http success' do
        visit = create :visit, advisor: current_user
        diagnosis = create :diagnosis, visit: visit
        get :show, params: { id: diagnosis.id, visit_id: visit.id }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
