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
    before do
      post :notify_experts, params: {
        id: diagnosis.id
      }
    end

    it 'returns http success' do
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
