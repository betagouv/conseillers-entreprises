# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DiagnosesController, type: :controller do
  login_user

  let(:visit) { create :visit, advisor: current_user }
  let(:content) { Faker::Lorem.paragraph }
  let(:diagnosis) { create :diagnosis, visit: visit, content: content }

  describe 'GET #show' do
    before { get :show, format: :json, params: { id: diagnosis.id } }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:updated_content) { 'Lorem fake stuff content' }

    before { patch :update, format: :json, params: { id: diagnosis.id, diagnosis: { content: updated_content } } }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
    it 'updates the diagnosis s content' do
      content = (Diagnosis.find diagnosis.id).content
      expect(content).to eq(updated_content)
    end
  end
end
