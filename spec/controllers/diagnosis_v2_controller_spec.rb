# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosisV2Controller, type: :controller do
  login_user

  let(:diagnosis) { create :diagnosis }

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #step2' do
    it 'returns http success' do
      diagnosis = create :diagnosis

      get :step2, params: { id: diagnosis.id }

      expect(response).to have_http_status(:success)
    end
  end
end
