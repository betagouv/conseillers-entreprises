# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosisController, type: :controller do
  login_user

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #answer' do
    it 'returns http success' do
      answer = create :answer
      get :answer, params: { id: answer.id }
      expect(response).to have_http_status(:success)
    end
  end
end
