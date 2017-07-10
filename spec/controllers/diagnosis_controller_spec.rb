# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosisController, type: :controller do
  login_user

  let(:visit) { create :visit, advisor: current_user }

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { visit_id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new, params: { visit_id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post :create, params: { visit_id: visit.id }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      diagnosis = create :diagnosis, visit: visit
      get :show, params: { id: diagnosis.id, visit_id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end
end
