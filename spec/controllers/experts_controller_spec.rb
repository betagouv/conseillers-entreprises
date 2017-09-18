# frozen_string_literal: true

require 'rails_helper'
RSpec.describe ExpertsController, type: :controller do
  let(:diagnosis) { create :diagnosis }

  describe 'GET #diagnosis' do
    it 'returns http success' do
      get :diagnosis, params: { diagnosis_id: diagnosis.id }
      expect(response).to have_http_status(:success)
    end
  end
end
