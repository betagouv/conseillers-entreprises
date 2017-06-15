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

  describe 'GET #question' do
    it 'returns http success' do
      question = create :question
      get :question, params: { id: question.id }
      expect(response).to have_http_status(:success)
    end
  end
end
